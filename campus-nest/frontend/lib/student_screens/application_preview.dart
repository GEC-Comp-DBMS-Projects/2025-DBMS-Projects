import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/student_screens/pdf_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../toast.dart';
import '../loader.dart'; 

class ApplicationPreviewPage extends StatefulWidget {
  final String jobId;

  const ApplicationPreviewPage({Key? key, required this.jobId})
    : super(key: key);

  @override
  State<ApplicationPreviewPage> createState() => _ApplicationPreviewPageState();
}

class _ApplicationPreviewPageState extends State<ApplicationPreviewPage> {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  String? _selectedResumeId;
  bool _isApplying = false;
  bool _isLoading = true; 
  Map<String, dynamic>? _studentProfile;
  Map<String, dynamic>? _jobDetails;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      AppToast.error(context, "Authentication error.");
      return;
    }

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
            'https://campusnest-backend-lkue.onrender.com/api/v1/profile/student',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse(
            'https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs/${widget.jobId}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        if (mounted) {
          setState(() {
            _studentProfile = jsonDecode(responses[0].body);
            _jobDetails = jsonDecode(responses[1].body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception(
          "Failed to load data. Profile Status: ${responses[0].statusCode}, Job Status: ${responses[1].statusCode}",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, "Error: $e");
      }
    }
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isApplying = true;
    });

    final token = await _getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() {
        _isApplying = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs/${widget.jobId}/apply',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'resume_id': _selectedResumeId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Application submitted successfully!',
                  style: GoogleFonts.montserrat(),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to submit application',
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('Error applying for job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'An error occurred',
                  style: GoogleFonts.montserrat(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isApplying = false;
        Navigator.pop(context);
      });
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CustomLoader(
                        primaryColor: primaryColor,
                        darkColor: darkColor,
                        lightColor: lightColor,
                        loadingText: "Loading Preview...",
                      ),
                    )
                  : _studentProfile == null || _jobDetails == null
                  ? _buildErrorState()
                  : _buildFormContent(),
            ),
            if (!_isLoading && _studentProfile != null) _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: lightColor, size: 48),
          const SizedBox(height: 16),
          Text(
            "Could not load application preview.",
            style: GoogleFonts.montserrat(color: lightColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final student = _studentProfile!;
    final List<dynamic> resumes = student['resumes'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(student),
            const Divider(height: 32),
            _buildResumeList(resumes),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: lightColor),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Application',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: lightColor,
                    ),
                  ),
                  Text(
                    _jobDetails?['position'] ?? 'Loading job...',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: lightColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: lightColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isApplying || _selectedResumeId == null
              ? null
              : _submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: lightColor,
            disabledBackgroundColor: grayColor.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isApplying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Submit Application',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR DETAILS",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: grayColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _infoTile(
          Icons.person_outline,
          "${student['firstName']} ${student['lastName']}",
        ),
        _infoTile(Icons.email_outlined, student['email']),
        _infoTile(Icons.school_outlined, "CGPA: ${student['cgpa']}"),
      ],
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: darkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeList(List<dynamic> resumes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT A RESUME TO APPLY",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: grayColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (resumes.isEmpty)
          const Center(
            child: Text(
              "You have no resumes to select. Please upload one first.",
            ),
          )
        else
          ...resumes.map((resume) {
            final fileUrl = resume['fileURL'] ?? '';
            final resumeId = resume['id'] ?? '';
            final uploadedAt = DateTime.tryParse(resume['uploadedAt'] ?? '');

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RadioListTile<String>(
                value: resumeId,
                groupValue: _selectedResumeId,
                onChanged: (String? value) {
                  setState(() => _selectedResumeId = value);
                },
                title: Text(
                  _getFilenameFromUrl(fileUrl),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: darkColor,
                  ),
                ),
                subtitle: Text(
                  uploadedAt != null
                      ? 'Uploaded ${_formatTimeAgo(uploadedAt)}'
                      : 'N/A',
                  style: GoogleFonts.montserrat(color: grayColor),
                ),
                activeColor: primaryColor,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: IconButton(
                  icon: Icon(Icons.visibility_outlined, color: primaryColor),
                  onPressed: () {
                    if (fileUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            url: fileUrl,
                            title: _getFilenameFromUrl(fileUrl),
                          ),
                        ),
                      );
                    } else {
                      AppToast.error(context, "Invalid resume link.");
                    }
                  },
                ),
                contentPadding: const EdgeInsets.only(left: 12, right: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: grayColor.withOpacity(0.1),
              ),
            );
          }).toList(),
      ],
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
    if (difference.inDays > 7) return DateFormat('d MMM yyyy').format(date);
    if (difference.inDays > 1) return '${difference.inDays} days ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minutes ago';
    return 'Just now';
  }
}
