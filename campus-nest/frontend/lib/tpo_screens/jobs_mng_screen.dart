import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_drive.dart'; 

class JobsManagementScreen extends StatefulWidget {
  const JobsManagementScreen({super.key});

  @override
  State<JobsManagementScreen> createState() => _JobsManagementScreenState();
}

class _JobsManagementScreenState extends State<JobsManagementScreen> {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  final TextEditingController searchController = TextEditingController();
  List<dynamic> drives = [];
  bool isLoading = true;
  String selectedFilter = 'All Drives';

  @override
  void initState() {
    super.initState();
    fetchDrives();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchDrives() async {
    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/tpo/drives',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched drives: $data');
        setState(() {
          drives = data['drives'] ?? [];
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching drives: $e');
      setState(() => isLoading = false);
    }
  }

  List<dynamic> getFilteredDrives() {
    List<dynamic> filtered = drives;

    if (selectedFilter == 'Upcoming') {
      filtered = drives.where((d) => d['status'] == 'Open').toList();
    } else if (selectedFilter == 'Completed') {
      filtered = drives.where((d) => d['status'] == 'Closed').toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered.where((drive) {
        final company = drive['company_name']['name']?.toString() ?? '';
        final role = drive['position']?.toString() ?? '';
        final query = searchController.text.toLowerCase();
        return company.contains(query) || role.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrives = getFilteredDrives();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : filteredDrives.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        itemCount: filteredDrives.length,
                        itemBuilder: (context, index) {
                          return _buildDriveCard(filteredDrives[index]);
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDrivePage(),
                  ),
                );
                if (result == true) {
                  fetchDrives();
                }
              },
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Create Drive',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        'Jobs Management',
        style: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkColor,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(() {}),
        style: GoogleFonts.montserrat(color: darkColor),
        decoration: InputDecoration(
          hintText: 'Search by role or company...',
          hintStyle: GoogleFonts.montserrat(color: grayColor),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          filled: true,
          fillColor: lightColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 8),
          _buildFilterChip('Upcoming'),
          const SizedBox(width: 7),
          _buildFilterChip('Completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? lightColor : darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No drives found.",
        style: GoogleFonts.montserrat(color: grayColor),
      ),
    );
  }

  Widget _buildDriveCard(Map<String, dynamic> drive) {
    final isLive = (drive['status']?.toLowerCase() ?? '') == 'open';
    final company = drive['company_name']?['name'] ?? 'Company';
    final role = drive['position'] ?? 'Position';

    String deadline = 'No deadline';
    if (drive['application_deadline'] != null) {
      deadline =
          "Deadline: ${DateFormat('d MMM yyyy').format(DateTime.parse(drive['application_deadline']))}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                company.isNotEmpty ? company[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deadline,
                  style: GoogleFonts.montserrat(fontSize: 12, color: grayColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLive
                  ? Colors.green.withOpacity(0.1)
                  : grayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isLive ? 'Live' : 'Closed',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLive ? Colors.green.shade700 : grayColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
