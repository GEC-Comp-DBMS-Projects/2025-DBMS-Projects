import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TPOProfileScreen extends StatefulWidget {
  final String title;
  const TPOProfileScreen({super.key, this.title = "Profile"});

  @override
  State<TPOProfileScreen> createState() => _TPOProfileScreenState();
}

class _TPOProfileScreenState extends State<TPOProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchProfile() async {
    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() => isLoading = false);
      return;
    } else {
      print('Token found: $token');
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/profile/tpo');

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
        print('Data: $data');
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('user_role');

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (Route<dynamic> route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: CustomPallete.primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildQualificationsCard(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 100), // Padding for the bottom nav bar
                  ],
                ),
              ),
            ),
    );
  }

  // --- UPDATED WIDGETS with new theme ---

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor, // Changed to light background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: CustomPallete.darkColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: CustomPallete.primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 40, color: CustomPallete.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profileData?['profile']['firstName'] ?? ''} ${profileData?['profile']['lastName'] ?? ''}',
                      style: GoogleFonts.montserrat(color: CustomPallete.darkColor, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: CustomPallete.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        (profileData?['profile']['role'] as String? ?? 'tpo').toUpperCase(),
                        style: GoogleFonts.montserrat(color: CustomPallete.primaryColor, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _contactRow(Icons.email_outlined, profileData?['profile']['email'] ?? 'N/A'),
          const SizedBox(height: 8),
          _contactRow(Icons.phone_outlined, profileData?['phone'] ?? 'Not Available'),
          // const SizedBox(height: 20),
          // ElevatedButton.icon(
          //   onPressed: () { /* Navigate to edit profile */ },
          //   icon: const Icon(Icons.edit, size: 16),
          //   label: Text('Edit Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: CustomPallete.primaryColor,
          //     foregroundColor: CustomPallete.lightColor,
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: CustomPallete.grayColor, size: 18),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.montserrat(color: CustomPallete.darkColor, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Students', profileData?['totalStudents']?.toString() ?? '0', Icons.school_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Drives', profileData?['actualDrives']?.toString() ?? '0', Icons.work_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Companies', profileData?['companiesOnboarded']?.toString() ?? '0', Icons.business_center_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: CustomPallete.darkColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: CustomPallete.primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: CustomPallete.darkColor)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: CustomPallete.grayColor)),
        ],
      ),
    );
  }

  Widget _buildQualificationsCard() {
    final qualifications = profileData?['profile']?['qualifications'] as List? ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: CustomPallete.darkColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qualifications', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: CustomPallete.darkColor)),
          const SizedBox(height: 16),
          if (qualifications.isNotEmpty)
            ...qualifications.map((q) => _buildQualificationChip(q.toString())).toList()
          else
            Text('No qualifications listed.', style: GoogleFonts.montserrat(color: CustomPallete.grayColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQualificationChip(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomPallete.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: GoogleFonts.montserrat(color: CustomPallete.primaryColor, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Logout',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.montserrat(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _logout(context);
                  },
                  child: Text(
                    'Logout',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFE74C3C),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C3E50),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logout',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.logout, size: 20),
          ],
        ),
      ),
    );
  }

}