import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart'; // Adjust path as needed

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};
  Map<String, dynamic> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // --- API Logic ---
  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchProfile() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/admin/dashboard'); 
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          // UPDATED: Parse the new API structure
          _profileData = data['user'] ?? {};
          _summaryData = data['summary'] ?? {};
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildStatisticsGrid(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildProfileCard() {
    String joinedDate = 'N/A';
    if (_profileData['createdAt'] != null) {
      joinedDate = DateFormat('MMMM yyyy').format(DateTime.parse(_profileData['createdAt']));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings_outlined, size: 40, color: CustomPallete.primaryColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_profileData['firstName'] ?? ''} ${_profileData['lastName'] ?? ''}',
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin / Head TPO',
                    style: GoogleFonts.montserrat(color: lightColor.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32, thickness: 0.5),
          _contactRow(Icons.email_outlined, _profileData['email'] ?? 'N/A'),
          const SizedBox(height: 8),
          _contactRow(Icons.calendar_today_outlined, 'Joined: $joinedDate'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: lightColor.withOpacity(0.7), size: 16),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.montserrat(color: lightColor, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Overall Statistics", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(title: 'Students', value: _summaryData['students']?.toString() ?? '0', icon: Icons.school_outlined, color1: Colors.blue.shade300, color2: Colors.blue.shade600),
            _StatCard(title: 'Companies', value: _summaryData['companies']?.toString() ?? '0', icon: Icons.business_center_outlined, color1: Colors.orange.shade300, color2: Colors.orange.shade600),
            _StatCard(title: 'Applications', value: _summaryData['applications']?.toString() ?? '0', icon: Icons.description_outlined, color1: Colors.purple.shade300, color2: Colors.purple.shade600),
            _StatCard(title: 'Shortlisted', value: _summaryData['shortlisted']?.toString() ?? '0', icon: Icons.star_outline_rounded, color1: Colors.green.shade300, color2: Colors.green.shade600),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: Icon(Icons.logout, color: Colors.red.shade400, size: 20),
      label: Text('Logout', style: GoogleFonts.montserrat(color: Colors.red.shade400, fontWeight: FontWeight.w600, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.1),
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color2.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(title, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withOpacity(0.9))),
            ],
          ),
        ],
      ),
    );
  }
}