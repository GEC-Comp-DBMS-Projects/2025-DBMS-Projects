import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../toast.dart'; // Make sure the path to your toast.dart is correct

// Enum to manage which form is visible
enum OnboardMode { newCompany, existingCompany }

// Helper class to manage controllers for each dynamic recruiter form
class RecruiterFormFields {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
  }
}

class OnboardCompanyPage extends StatefulWidget {
  const OnboardCompanyPage({Key? key}) : super(key: key);

  @override
  State<OnboardCompanyPage> createState() => _OnboardCompanyPageState();
}

class _OnboardCompanyPageState extends State<OnboardCompanyPage> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  final _formKey = GlobalKey<FormState>();
  OnboardMode _currentMode = OnboardMode.newCompany;
  
  // Controllers for new company fields
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();

  // State for existing company dropdown
  List<dynamic> _companies = [];
  bool _isLoadingCompanies = true;
  Map<String, dynamic>? _selectedCompany;

  // State for dynamic recruiter fields
  List<RecruiterFormFields> _recruiterForms = [RecruiterFormFields()];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    for (var form in _recruiterForms) {
      form.dispose();
    }
    super.dispose();
  }

  // --- API Logic ---
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchCompanies() async {
    // Assuming this is the endpoint to get all companies
    final url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/admin/companies");
    try {
      final token = await _getToken();
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _companies = jsonDecode(response.body)['companies'] ?? [];
          _isLoadingCompanies = false;
        });
      } else {
        if(mounted) setState(() => _isLoadingCompanies = false);
      }
    } catch (e) {
      if(mounted) setState(() => _isLoadingCompanies = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, "Please fix the errors in the form.");
      return;
    }

    setState(() => _isSubmitting = true);
    final token = await _getToken();

    // The list of recruiters is the same for both modes
    final recruiters = _recruiterForms.map((form) => {
      'firstName': form.firstNameController.text,
      'lastName': form.lastNameController.text,
      'email': form.emailController.text,
    }).toList();

    Uri url;
    dynamic body;

    // Conditional logic based on the selected mode
    if (_currentMode == OnboardMode.newCompany) {
      url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/admin/company");
      body = {
        'companyName': _companyNameController.text,
        'industry': _industryController.text,
        'website': _websiteController.text,
        'recruiters': recruiters,
      };
    } else {
      url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/admin/company/${_selectedCompany!['_id']}/recruiter");
      body = {
        'recruiters': recruiters,
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );

      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          AppToast.success(context, "Operation successful!");
          Navigator.pop(context, true); // Pop with a success result
        } else {
          AppToast.error(context, "Failed: ${response.body}");
        }
      }
    } catch (e) {
      if(mounted) AppToast.error(context, "An error occurred: $e");
    } finally {
      if(mounted) setState(() => _isSubmitting = false);
    }
  }
  
  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [secondaryColor, grayColor, primaryColor],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModeToggle(),
                        const SizedBox(height: 24),
                        if (_currentMode == OnboardMode.newCompany)
                          _buildNewCompanyFields()
                        else
                          _buildExistingCompanyDropdown(),
                        
                        const Divider(height: 40),
                        
                        _buildRecruiterFields(),
                        
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 20, 20),
        child: Row(
          children: [
            // Back Button
            Container(
              decoration: BoxDecoration(
                color: lightColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: lightColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            // Page Title
            Text(
              'Onboard Company',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: lightColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeToggle() {
    return SegmentedButton<OnboardMode>(
      segments: const [
        ButtonSegment(value: OnboardMode.newCompany, label: Text('New Company'), icon: Icon(Icons.business)),
        ButtonSegment(value: OnboardMode.existingCompany, label: Text('Existing'), icon: Icon(Icons.add_circle_outline)),
      ],
      selected: {_currentMode},
      onSelectionChanged: (Set<OnboardMode> newSelection) {
        setState(() => _currentMode = newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: lightColor,
        foregroundColor: grayColor,
        selectedBackgroundColor: primaryColor,
        selectedForegroundColor: lightColor,
      ),
    );
  }

  Widget _buildNewCompanyFields() {
    return Column(
      children: [
        _buildTextField(_companyNameController, "Company Name", Icons.business_center_outlined),
        _buildTextField(_industryController, "Industry (e.g., Tech)", Icons.category_outlined),
        _buildTextField(_websiteController, "Company Website", Icons.language_outlined),
      ],
    );
  }

  Widget _buildExistingCompanyDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedCompany,
        isExpanded: true,
        decoration: _inputDecoration("Select Company", Icons.business_center_outlined),
        hint: Text(_isLoadingCompanies ? "Loading companies..." : "Select a company", style: GoogleFonts.montserrat(color: grayColor)),
        items: _companies.map<DropdownMenuItem<Map<String, dynamic>>>((company) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: company,
            child: Text(company['name'] ?? 'Unknown Company'),
          );
        }).toList(),
        onChanged: (Map<String, dynamic>? newValue) {
          setState(() => _selectedCompany = newValue);
        },
        validator: (value) => value == null ? 'Please select a company' : null,
      ),
    );
  }

  Widget _buildRecruiterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recruiters to Add", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
        const SizedBox(height: 16),
        ..._recruiterForms.asMap().entries.map((entry) {
          int idx = entry.key;
          RecruiterFormFields form = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recruiter ${idx + 1}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: primaryColor)),
                    if (_recruiterForms.length > 1)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                        onPressed: () => setState(() => _recruiterForms.removeAt(idx)),
                      )
                  ],
                ),
                _buildTextField(form.firstNameController, "First Name", null),
                _buildTextField(form.lastNameController, "Last Name", null),
                _buildTextField(form.emailController, "Email Address", null, keyboardType: TextInputType.emailAddress),
              ],
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Another Recruiter"),
            onPressed: () => setState(() => _recruiterForms.add(RecruiterFormFields())),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submitForm,
      icon: _isSubmitting ? Container(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, size: 18),
      label: Text(_isSubmitting ? "Submitting..." : (_currentMode == OnboardMode.newCompany ? "Onboard Company" : "Add Recruiters")),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }

 Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData? icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(color: darkColor, fontSize: 15),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
      ),
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: grayColor, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: primaryColor, size: 20) : null,
      filled: true,
      fillColor: primaryColor.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: grayColor.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: grayColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}