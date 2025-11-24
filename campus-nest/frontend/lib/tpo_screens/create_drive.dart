import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../toast.dart';

class CreateDrivePage extends StatefulWidget {
  const CreateDrivePage({Key? key}) : super(key: key);

  @override
  State<CreateDrivePage> createState() => _CreateDrivePageState();
}

class _CreateDrivePageState extends State<CreateDrivePage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _locationController = TextEditingController();
  final _minCGPAController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _maxBacklogsController = TextEditingController();

  List<dynamic> _companies = [];
  bool _isLoadingCompanies = true;
  Map<String, dynamic>? _selectedCompany;

  List<String> _selectedCourses = [];
  List<String> _selectedSkills = [];
  List<String> _selectedBatch = [];
  DateTime? _applicationDeadline;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchCompanies(); 
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    // ... dispose other controllers
    super.dispose();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchCompanies() async {
    setState(() => _isLoadingCompanies = true);
    final token = await getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoadingCompanies = false);
      return;
    }
    final url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/tpo/companies");
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        print('Fetched companies: ${response.body}');
        setState(() {
          _companies = jsonDecode(response.body)['companies'] ?? [];
          _isLoadingCompanies = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingCompanies = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCompanies = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, "Please fix the errors and fill all required fields.");
      return;
    }

    setState(() => _isLoading = true);
    final token = await getToken();
    final url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/tpo/drives");
    
    final body = {
      "company_name": {
        "companyId": _selectedCompany!['ID'],
        "name": _selectedCompany!['Name']
      },
      "position": _positionController.text,
      "description": _descriptionController.text,
      "salary_range": _salaryRangeController.text,
      "location": _locationController.text,
      "application_deadline": _applicationDeadline!.toIso8601String() + 'Z',
      "eligibility": {
        "min_cgpa": double.tryParse(_minCGPAController.text) ?? 0,
        "course": _selectedCourses,
        "skills": _selectedSkills,
        "batch": _selectedBatch.map((e) => int.parse(e)).toList(),
        "graduation_year": int.tryParse(_graduationYearController.text) ?? 0,
        "max_backlogs": int.tryParse(_maxBacklogsController.text) ?? 0,
      },
    };

    print('Submitting drive: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          AppToast.success(context, "Drive created successfully!");
          Navigator.pop(context, true); 
        } else {
          AppToast.error(context, "Failed: ${response.body}");
        }
      }
    } catch (e) {
      if (mounted) AppToast.error(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CustomPallete.lightTeal, CustomPallete.primaryColor, CustomPallete.darkColor],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: CustomPallete.lightColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: CustomPallete.darkColor,
                          blurRadius: 5,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Basic Information", Icons.business_rounded),
                          const SizedBox(height: 20),
                          _buildCompanyDropdown(),
                          _buildTextField(_positionController, "Position / Role", Icons.work_outline_rounded),
                          _buildTextField(_descriptionController, "Job Description", Icons.description_outlined, maxLines: 4),
                          _buildTextField(_salaryRangeController, "Salary Range (e.g., 10-12 LPA)", Icons.attach_money_outlined),
                          _buildTextField(_locationController, "Location", Icons.location_on_outlined),
                          
                          const SizedBox(height: 32),
                          Divider(color: CustomPallete.grayColor, thickness: 1),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader("Eligibility Criteria", Icons.checklist_rounded),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_minCGPAController, "Min CGPA", Icons.stars_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTextField(_maxBacklogsController, "Max Backlogs", Icons.warning_amber_rounded, keyboardType: TextInputType.number)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_graduationYearController, "Graduation Year", Icons.calendar_today_outlined, keyboardType: TextInputType.number)),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          _buildMultiSelectFormField(title: "Eligible Courses", list: _selectedCourses, icon: Icons.school_outlined),
                          _buildMultiSelectFormField(title: "Required Skills", list: _selectedSkills, icon: Icons.lightbulb_outline_rounded),
                          _buildMultiSelectFormField(title: "Eligible Batches", list: _selectedBatch, icon: Icons.groups_outlined),
                          
                          const SizedBox(height: 8),
                          _buildDatePickerFormField(),
                          
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                        ],
                      ),
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

  Widget _buildCompanyDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedCompany,
        isExpanded: true,
        decoration: _inputDecoration("Company Name", Icons.business_center_outlined),
        hint: Text(
          _isLoadingCompanies ? "Loading companies..." : "Select a company",
          style: GoogleFonts.montserrat(color: CustomPallete.grayColor),
        ),
        items: _companies.map<DropdownMenuItem<Map<String, dynamic>>>((company) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: company,
            child: Text(
              company['Name'] ?? 'Unknown Company',
              style: GoogleFonts.montserrat(color: CustomPallete.darkColor, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: (Map<String, dynamic>? newValue) {
          setState(() => _selectedCompany = newValue);
        },
        validator: (value) => value == null ? 'Company Name is required' : null,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CustomPallete.darkColor.withOpacity(0.3), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: CustomPallete.lightColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: CustomPallete.darkColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Drive',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: CustomPallete.darkColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Fill in the job drive details',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: CustomPallete.lightColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CustomPallete.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: CustomPallete.lightColor, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomPallete.darkColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: CustomPallete.grayColor, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: CustomPallete.primaryColor, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: CustomPallete.grayColor.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: CustomPallete.grayColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: CustomPallete.primaryColor, width: 2),
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
        style: GoogleFonts.montserrat(color: CustomPallete.darkColor, fontSize: 15),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildMultiSelectFormField({
    required String title,
    required List<String> list,
    required IconData icon,
  }) {
    final TextEditingController inputController = TextEditingController();
    return FormField<List<String>>(
      initialValue: list,
      validator: (value) => (value == null || value.isEmpty) ? 'Please add at least one item' : null,
      builder: (formFieldState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CustomPallete.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: formFieldState.hasError
                  ? Colors.red.withOpacity(0.5)
                  : CustomPallete.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomPallete.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: CustomPallete.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: CustomPallete.darkColor,
                    ),
                  ),
                ],
              ),
              if (list.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: list.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CustomPallete.primaryColor.withOpacity(0.2), CustomPallete.primaryColor.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CustomPallete.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: GoogleFonts.montserrat(
                            color: CustomPallete.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              list.remove(item);
                              formFieldState.didChange(list);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: CustomPallete.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      style: GoogleFonts.montserrat(color: CustomPallete.darkColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Type here...",
                        hintStyle: GoogleFonts.montserrat(color: CustomPallete.grayColor.withOpacity(0.6)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            list.add(value.trim());
                            inputController.clear();
                            formFieldState.didChange(list);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CustomPallete.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      onPressed: () {
                        if (inputController.text.trim().isNotEmpty) {
                          setState(() {
                            list.add(inputController.text.trim());
                            inputController.clear();
                            formFieldState.didChange(list);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        formFieldState.errorText!,
                        style: GoogleFonts.montserrat(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePickerFormField() {
    return FormField<DateTime>(
      initialValue: _applicationDeadline,
      validator: (value) => value == null ? 'Please select an application deadline' : null,
      builder: (formFieldState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: formFieldState.hasError
                  ? Colors.red.withOpacity(0.5)
                  : CustomPallete.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: CustomPallete.primaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CustomPallete.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event_rounded, color: CustomPallete.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Application Deadline",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: CustomPallete.grayColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _applicationDeadline == null
                              ? "Not selected"
                              : DateFormat('EEEE, d MMMM yyyy').format(_applicationDeadline!),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: _applicationDeadline == null ? CustomPallete.grayColor.withOpacity(0.6) : CustomPallete.darkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: CustomPallete.primaryColor,
                                onPrimary: Colors.white,
                                surface: CustomPallete.lightColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _applicationDeadline = picked;
                          formFieldState.didChange(picked);
                        });
                      }
                    },
                    icon: Icon(
                      _applicationDeadline == null ? Icons.calendar_today_outlined : Icons.edit_calendar_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _applicationDeadline == null ? "Select" : "Change",
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomPallete.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        formFieldState.errorText!,
                        style: GoogleFonts.montserrat(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLoading
              ? [CustomPallete.grayColor, CustomPallete.grayColor.withOpacity(0.8)]
              : [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoading ? [] : [
          BoxShadow(
            color: CustomPallete.primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    "Create Drive",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}