import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/chatbot.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/student_screens/resume.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/student_screens/resume_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../custom_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import '../screens/editProf_screen.dart';

Future<void> saveSkillProficiencies(Map<String, double> proficiencies) async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, dynamic> serializableMap = proficiencies.map((key, value) => MapEntry(key, value));
  final String jsonString = jsonEncode(serializableMap);
  await prefs.setString('skill_proficiencies', jsonString);
}

Future<Map<String, double>> loadSkillProficiencies() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonString = prefs.getString('skill_proficiencies');
  if (jsonString != null) {
    try {
      final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
      return decodedMap.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      print('Error decoding skill proficiencies: $e');
      return {};
    }
  }
  return {};
}
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadAndFetchProfile();
  }

  static const Color primaryColor = Color(0xFF5D9493);
  static const Color secondaryColor = Color(0xFF8CA1A4);
  static const Color darkColor = Color(0xFF21464E);
  static const Color lightColor = Color(0xFFF8F9F9);
  static const Color grayColor = Color(0xFFA1B5B7);
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? dashboardInfo;
  bool isLoading = true;

  Map<String, double> skillProficiencies = {};
  final Random _random = Random();

  Future<void> _loadAndFetchProfile() async {
    final loadedProficiencies = await loadSkillProficiencies();
    if (mounted) {
      setState(() {
        skillProficiencies = loadedProficiencies;
        if (profileData == null) {
          isLoading = true; 
        }
      });
    }

    await fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor, 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFEBFBFA), primaryColor, darkColor],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppHeader(
                onProfileTap: () {},
                primaryColor: primaryColor,
                darkColor: darkColor,
                lightColor: lightColor,
                onNotificationTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage())
                )
              ),
              Expanded(
                child: isLoading
                  ? Center(child: CircularProgressIndicator(color: lightColor))
                  : RefreshIndicator(
                    onRefresh: fetchProfile,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileHeader(),
                          const SizedBox(height: 24),
                          _statsCards(),
                          const SizedBox(height: 24),
                          _resumeSection(), 
                          const SizedBox(height: 24),
                          _skillsSection(),
                          const SizedBox(height: 24),
                          _achievementsSection(),
                          const SizedBox(height: 32),
                          _aiChatbotCard(),
                          const SizedBox(height: 20),
                          _buildLogoutButton(),
                          const SizedBox(height: 65),
                        ],
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, darkColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: lightColor.withOpacity(0.3), width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: lightColor,
                  child: Icon(Icons.person, color: primaryColor, size: 40),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profileData?['firstName'] ?? 'Loading...'} ${profileData?['lastName'] ?? ''}',
                      style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: lightColor),
                    ),
                    const SizedBox(height: 8),
                    _infoChip('${profileData?['department'] ?? 'Loading...'}', Icons.school),
                    const SizedBox(height: 4),
                    _infoChip('CGPA: ${profileData?["cgpa"] ?? "N/A"}', Icons.star),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: lightColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${profileData?['email'] ?? 'Loading...'}',
                      style: GoogleFonts.montserrat(color: lightColor.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, color: lightColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '+91 12345 67890',
                      style: GoogleFonts.montserrat(color: lightColor.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
              fetchProfile();
            },
            icon: const Icon(Icons.edit, size: 18),
            label: Text('Edit Profile', style: GoogleFonts.montserrat()),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightColor,
              foregroundColor: darkColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: lightColor, size: 16),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.montserrat(color: lightColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statsCards() {
    return Row(
      children: [
        Expanded(child: _statCard(dashboardInfo?['summary']['applied'].toString() ?? '0', 'Application', Icons.work_outline)),
        const SizedBox(width: 16),
        Expanded(child: _statCard(dashboardInfo?['summary']['shortlisted'].toString() ?? '0', 'Interviews', Icons.calendar_today)),
        const SizedBox(width: 16),
        Expanded(child: _statCard(dashboardInfo?['summary']['offered'].toString() ?? '0', 'Offers', Icons.local_offer_outlined)),
      ],
    );
  }

  Widget _statCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(number, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: darkColor)),
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: grayColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  
  Widget _resumeSection() {
    final List<dynamic> resumes = profileData?['resumes'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.description, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'My Resumes',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: darkColor),
              ),
            ],
          ),
          const Divider(height: 24),
          
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (resumes.isEmpty)
            Center(child: Text("No resumes uploaded yet.", style: GoogleFonts.montserrat(color: grayColor, fontSize: 14)))
          else
            Column(
              children: resumes.map((resume) => _buildResumeTile(resume)).toList(),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResumeParserPage()),
                );
                if (result == true) {
                  fetchProfile();
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload New Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: lightColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeTile(Map<String, dynamic> resume) {
    final fileUrl = resume['fileURL'] ?? '';
    final resumeId = resume['id'] ?? '';
    final resumeName = resume['ResumeName'] ?? resume['fileURL'];
    final uploadedAt = DateTime.tryParse(resume['uploadedAt'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grayColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumeName ??  _getFilenameFromUrl(fileUrl),
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: darkColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (uploadedAt != null)
                      Text(
                        'Uploaded ${_formatTimeAgo(uploadedAt)}',
                        style: GoogleFonts.montserrat(fontSize: 12, color: grayColor),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: grayColor),
                onSelected: (value) async {
                  if (value == 'view') {
                    if (fileUrl.isNotEmpty) {
                      final uri = Uri.parse(fileUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.open_in_new), SizedBox(width: 8), Text('View')])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResumeReviewPage(
                      resumeId: resumeId,
                      resumeFileUrl: fileUrl,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.auto_awesome_outlined, size: 18, color: primaryColor),
              label: Text("Analyze with AI", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilenameFromUrl(String url) {
    try {
      return Uri.decodeComponent(url.split('/').last.split('?').first);
    } catch (e) {
      return 'resume.pdf';
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('d MMM yyyy').format(date);
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
Widget _skillEntry(String skill, double proficiency) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: GoogleFonts.montserrat(
              color: lightColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8), 
          
          Container(
            width: double.infinity, 
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: proficiency.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillsSection() {
    final List<dynamic> skillsList = (profileData?['skills'] as List<dynamic>? ?? []);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.9), darkColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: lightColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Skills Portfolio',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: lightColor,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Generated',
                  style: GoogleFonts.montserrat(
                    color: lightColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Column(
            children: [
              if (isLoading && skillsList.isEmpty)
                _skillEntry('Loading...', 0.5) 
              else if (skillsList.isEmpty)
                _skillEntry('No skills found', 0.0)
              else
                ...skillsList.map<Widget>((skill) {
                  String name = 'Unknown Skill';

                  if (skill is String) {
                    name = skill;
                  } else if (skill is Map) {
                    name = skill['name']?.toString() ?? 'Skill';
                  }
                  
                  double proficiency = skillProficiencies[name] ?? 0.5; 

                  return _skillEntry(name, proficiency);
                }).toList(),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: lightColor.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Skills extracted and analyzed from your resume',
                    style: GoogleFonts.montserrat(
                      color: lightColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _achievementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.emoji_events, color: Colors.amber),
              ),
              const SizedBox(width: 12),
              Text(
                'Achievements',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: darkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _achievementItem(
            'Dean\'s List',
            'Academic Excellence 2023',
            Icons.school,
          ),
          _achievementItem(
            'Hackathon Winner',
            'CodeFest 2023 - 1st Place',
            Icons.code,
          ),
          _achievementItem(
            'Research Publication',
            'AI in Healthcare - IEEE',
            Icons.article,
          ),
        ],
      ),
    );
  }

  Widget _achievementItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(fontSize: 12, color: grayColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiChatbotCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Career Assistant',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get personalized career advice and interview preparation tips',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 14, color: primaryColor),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatbotPage(),
                ),
              );
            },
            icon: Icon(Icons.chat),
            label: Text('Start Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: lightColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
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

  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? '';
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchProfile() async {
    final token = await getToken();
    final role = await getRole();
    if (token.isEmpty) {
      print('No token found');
      if (mounted) setState(() => isLoading = false);
      return;
    } 

    final urlProfile = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/profile/$role');
    final urlDashboard = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/dashboard/$role',
    );

    try {
      Map<String, double> savedProficiencies = await loadSkillProficiencies();

      Map<String, dynamic>? newProfileData;
      Map<String, dynamic>? newDashboardInfo;
      Map<String, double> newProficiencies = {}; 

      final responseProfile = await http.get(
        urlProfile,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (responseProfile.statusCode == 200) {
        final data = jsonDecode(responseProfile.body);
        print('Data: $data');
        newProfileData = data; 

        final List<dynamic> apiSkills = (data?['skills'] as List<dynamic>? ?? []);
        
        Set<String> apiSkillNames = {};

        for (final skill in apiSkills) {
          String name;
          double? apiProficiency;

          if (skill is String) {
            name = skill;
          } else if (skill is Map) {
            name = skill['name']?.toString() ?? 'Skill';
            final raw = skill['proficiency'];
            if (raw is num) {
              apiProficiency = raw.toDouble();
              if (apiProficiency > 1) apiProficiency = (apiProficiency / 100).clamp(0.0, 1.0);
              apiProficiency = apiProficiency.clamp(0.0, 1.0);
            }
          } else {
            continue; 
          }

          apiSkillNames.add(name); 

          if (apiProficiency != null) {
            newProficiencies[name] = apiProficiency;
          } else if (savedProficiencies.containsKey(name)) {
            newProficiencies[name] = savedProficiencies[name]!;
          } else {
            double newProf = 0.3 + (_random.nextDouble() * 0.7);
            newProficiencies[name] = newProf.clamp(0.0, 1.0);
          }
        }

        savedProficiencies.keys.where((skillName) => !apiSkillNames.contains(skillName))
          .toList() 
          .forEach((removedSkill) {
            savedProficiencies.remove(removedSkill);
          });

        await saveSkillProficiencies(newProficiencies);

      } else {
        print('Failed to load profile: ${responseProfile.body}');
        newProficiencies = savedProficiencies;
      }

      final responseDashboard = await http.get(
        urlDashboard,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (responseDashboard.statusCode == 200) {
        final dashboardData = jsonDecode(responseDashboard.body);
        print('Dashboard Data: $dashboardData');
        newDashboardInfo = dashboardData;
      } else {
        print('Failed to load dashboard: ${responseDashboard.body}');
      }
      
      if (mounted) {
        setState(() {
          if (newProfileData != null) {
            profileData = newProfileData;
          }
          if (newDashboardInfo != null) {
            dashboardInfo = newDashboardInfo;
          }
          skillProficiencies = newProficiencies; 
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error fetching profile: $e');
      if (mounted) setState(() => isLoading = false);
    }
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