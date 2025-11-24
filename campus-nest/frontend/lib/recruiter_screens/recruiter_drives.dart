import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/recruiter_screens/job_drive_details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterDrivesScreen extends StatefulWidget {
  const RecruiterDrivesScreen({Key? key}) : super(key: key);

  @override
  State<RecruiterDrivesScreen> createState() => _RecruiterDrivesScreenState();
}

class _RecruiterDrivesScreenState extends State<RecruiterDrivesScreen> {
  int _selectedIndex = 1;
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  String _selectedFilter = 'All Drives';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _jobDrives = [];
  List<dynamic> _filteredDrives = [];

  @override
  void initState() {
    super.initState();
    fetchJobDrives();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchJobDrives() async {
    setState(() => _isLoading = true);
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        print('Fetched job drives: $data');
        setState(() {
          _jobDrives = data['jobDrives'] ?? [];
          _filteredDrives = _jobDrives;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
        print('Failed to load job drives: ${response.body}');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, primaryColor, darkColor],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  CustomAppHeader(
                    onProfileTap: () => setState(() => _selectedIndex = 4),
                    primaryColor: CustomPallete.primaryColor,
                    darkColor: CustomPallete.darkColor,
                    lightColor: CustomPallete.lightColor,
                    onNotificationTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      ),
                    },
                  ),
                  _buildSearchBar(),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Current Drives',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: lightColor),
                          )
                        : _filteredDrives.isEmpty
                        ? Center(
                            child: Text(
                              "No job drives found.",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _filteredDrives.length,
                            itemBuilder: (context, index) =>
                                _buildDriveCard(_filteredDrives[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveCard(Map<String, dynamic> drive) {
  final isLive = drive['status'] == 'Open';
  final statusColor = isLive ? Colors.green : grayColor;
  final statusBgColor = isLive ? Colors.green.withOpacity(0.15) : grayColor.withOpacity(0.15);
  String formattedDate = 'No Deadline';
  if (drive['application_deadline'] != null) {
    final deadline = DateTime.tryParse(drive['application_deadline']);
    if (deadline != null) {
      formattedDate = 'Deadline: ${DateFormat('d MMM yyyy').format(deadline)}';
    }
  }

  return GestureDetector(
    onTap: () {
      final String jobId = drive['_id']; 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDriveDetailsPage(jobId: jobId),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drive['company_name']?['name'] ?? 'Company Name',
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      drive['position'] ?? 'Position',
                      style: GoogleFonts.montserrat(fontSize: 15, color: darkColor, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style: GoogleFonts.montserrat(fontSize: 13, color: primaryColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  drive['status'] ?? 'N/A',
                  style: GoogleFonts.montserrat(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Applicants: ${drive['totalApplications'] ?? 0}',
                    style: GoogleFonts.montserrat(fontSize: 13, color: primaryColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Shortlisted: ${drive['shortlistedCount'] ?? 0}',
                    style: GoogleFonts.montserrat(fontSize: 13, color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: lightColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: darkColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.montserrat(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by role, company, or keyword',
            hintStyle: GoogleFonts.montserrat(
              color: grayColor.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.menu, color: grayColor),
            suffixIcon: Icon(Icons.search, color: grayColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Drives', 'Upcoming', 'Past Drives'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) => _buildFilterChip(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? lightColor.withOpacity(0.95)
              : lightColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? darkColor.withOpacity(0.2) : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: darkColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: darkColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(Icons.work_outline, 'Job Drives', 1),
          _buildNavItem(Icons.description_outlined, 'Applications', 2),
          _buildNavItem(Icons.notifications_outlined, 'Notifications', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isSelected ? primaryColor : grayColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: isSelected ? primaryColor : grayColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
