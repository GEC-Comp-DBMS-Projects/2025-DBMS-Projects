import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> profileData = {
    "firstName": "",
    "lastName": "",
    "email": "",
    "cgpa": 0.0,
    "skills": [],
    "achievements": [],
  };

  final skillsController = TextEditingController();
  final achievementTitleController = TextEditingController();
  final achievementDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'student';
  }

  Future<void> fetchProfile() async {
    final token = await getToken();
    final role = await getRole();
    if (token.isEmpty) return;

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/profile/$role');
    final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        profileData = {
          "firstName": data["firstName"] ?? "John",
          "lastName": data["lastName"] ?? "Doe",
          "email": data["email"] ?? "johndoe@example.com",
          "cgpa": data["cgpa"] ?? 8.0,
          "skills": List<String>.from(data["skills"] ?? []),
          "achievements": List<dynamic>.from(data["achievements"] ?? []),
        };
        isLoading = false;
      });
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    final token = await getToken();
    final role = await getRole();
    final body = {"skills": profileData["skills"], "achievements": profileData["achievements"]};
    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/profile/$role');

    final response = await http.put(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(body));

    if (response.statusCode == 200) {
      AppToast.success(context, 'Profile updated successfully');
      Navigator.pop(context);
    } else {
      AppToast.error(context, 'Failed to update profile. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [secondaryColor, grayColor, primaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: lightColor))
                    : _buildProfileForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
     return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: lightColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            'Edit Profile',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: lightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildSectionCard(
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, "${profileData["firstName"]} ${profileData["lastName"]}"),
                _buildInfoRow(Icons.email_outlined, "${profileData["email"]}"),
                _buildInfoRow(Icons.star_border, "CGPA: ${profileData["cgpa"]}"),
              ],
            ),
          ),
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Skills", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: List<String>.from(profileData["skills"])
                      .map((skill) => Chip(
                            label: Text(skill, style: GoogleFonts.montserrat(color: primaryColor, fontWeight: FontWeight.w600)),
                            backgroundColor: primaryColor.withOpacity(0.15),
                            deleteIcon: Icon(Icons.close, size: 16, color: primaryColor),
                            onDeleted: () => setState(() => profileData["skills"].remove(skill)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          )).toList(),
                ),
                const SizedBox(height: 12),
                _buildSingleInputField(
                  controller: skillsController,
                  labelText: 'Add Skill',
                  onAdd: () {
                    if (skillsController.text.trim().isNotEmpty) {
                      setState(() {
                        profileData["skills"].add(skillsController.text.trim());
                        skillsController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Achievements", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 12),
                ... (profileData["achievements"] as List<dynamic>)
                    .map((ach) => _buildAchievementTile(ach, 
                        onDeleted: () => setState(() => profileData["achievements"].remove(ach))
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: achievementTitleController,
                  style: GoogleFonts.montserrat(color: darkColor),
                  decoration: _inputDecoration('Title (e.g., Hackathon Winner)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: achievementDescController,
                  style: GoogleFonts.montserrat(color: darkColor),
                  decoration: _inputDecoration('Description (e.g., CodeFest 2023 - 1st Place)'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (achievementTitleController.text.isNotEmpty && achievementDescController.text.isNotEmpty) {
                        setState(() {
                          profileData["achievements"].add({
                            'title': achievementTitleController.text.trim(),
                            'description': achievementDescController.text.trim(),
                          });
                          achievementTitleController.clear();
                          achievementDescController.clear();
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('+ Add Achievement', style: GoogleFonts.montserrat(color: primaryColor, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: lightColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text("Save Changes", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Map<String, dynamic> achievement, {required VoidCallback onDeleted}) {
    IconData iconData = Icons.emoji_events_outlined;
    String title = achievement['title']?.toLowerCase() ?? '';
    if (title.contains('dean') || title.contains('academic')) iconData = Icons.school_outlined;
    if (title.contains('hackathon') || title.contains('code')) iconData = Icons.code;
    if (title.contains('publication') || title.contains('paper')) iconData = Icons.article_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: grayColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: darkColor.withOpacity(0.7)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? 'No Title',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: darkColor, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement['description'] ?? 'No Description',
                  style: GoogleFonts.montserrat(color: grayColor, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
            onPressed: onDeleted,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.montserrat(color: darkColor, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildSingleInputField({required TextEditingController controller, required String labelText, required VoidCallback onAdd}) {
    return Row(children: [
        Expanded(child: TextField(controller: controller, style: GoogleFonts.montserrat(color: darkColor), decoration: _inputDecoration(labelText))),
        const SizedBox(width: 8),
        IconButton(icon: Icon(Icons.add_circle, color: primaryColor, size: 30), onPressed: onAdd),
      ],
    );
  }
  
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.montserrat(color: grayColor),
      filled: true,
      fillColor: Colors.black.withOpacity(0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
    );
  }
}