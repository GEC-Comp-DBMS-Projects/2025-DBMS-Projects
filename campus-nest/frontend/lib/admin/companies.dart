import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/admin/admin_profile.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardCompanyPage extends StatelessWidget {
  final String? companyId;
  const OnboardCompanyPage({Key? key, this.companyId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Onboard Company Form")));
}
// ----------------------------

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  List<dynamic> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  // --- API Logic ---
  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchCompanies() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    // Assuming this is the GET endpoint for all companies
    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/admin/companies');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _companies = jsonDecode(response.body)['companies'] ?? [];
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Navigation ---
  Future<void> _navigateAndRefresh({String? companyId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardCompanyPage(companyId: companyId),
      ),
    );
    if (result == true) {
      _fetchCompanies();
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Company', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          CustomAppHeader(
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminProfilePage(),
                    ),
                  );
                },
                onNotificationTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                ),
                primaryColor: primaryColor,
                darkColor: darkColor,
                lightColor: lightColor,
              ),
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    itemCount: _companies.length,
                    itemBuilder: (context, index) {
                      return _CompanyCard(
                        company: _companies[index],
                        onAddRecruiter: (companyId) => _navigateAndRefresh(companyId: companyId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Manage Companies',
          style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: darkColor),
        ),
      ),
    );
  }
}

// --- Company Card Widget ---
class _CompanyCard extends StatefulWidget {
  final Map<String, dynamic> company;
  final Function(String companyId) onAddRecruiter;

  const _CompanyCard({required this.company, required this.onAddRecruiter});

  @override
  State<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<_CompanyCard> {
  bool _isExpanded = false;

  final Color primaryColor = const Color(0xFF5D9493);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    final companyName = widget.company['name'] ?? 'N/A';
    final industry = widget.company['industry'] ?? 'N/A';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(companyName[0], style: GoogleFonts.montserrat(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(companyName, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
                      Text(industry, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[400]),
              ],
            ),
            // The expandable section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                height: _isExpanded ? null : 0,
                child: _buildExpandedView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Column(
      children: [
        const Divider(height: 32),
        ElevatedButton.icon(
          onPressed: () => widget.onAddRecruiter(widget.company['_id']),
          icon: const Icon(Icons.person_add_outlined, size: 18),
          label: Text("Add New Recruiter", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: lightColor,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )
      ],
    );
  }
}