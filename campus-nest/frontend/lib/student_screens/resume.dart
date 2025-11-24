import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResumeParserPage extends StatefulWidget {
  const ResumeParserPage({super.key});

  @override
  State<ResumeParserPage> createState() => _ResumeParserPageState();
}

class _ResumeParserPageState extends State<ResumeParserPage> {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool _loading = false;
  String? _result;
  String? _resumeName;

  Future<Map<String, dynamic>?> fetchProfile() async {
    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      return null;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/profile/student',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      print('Failed to load profile: ${response.body}');
      return null;
    }
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _pickAndUploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) return;

      Uint8List? fileBytes = result.files.single.bytes;
      String fileName = result.files.single.name;

      setState(() {
        _loading = true;
        _result = "Uploading: $fileName...";
      });

      String cloudName = "dd6jsu194";
      String uploadPreset = "campusNest";

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(fileBytes!, filename: fileName),
        "upload_preset": uploadPreset,
      });

      var response = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
        data: formData,
      );
      print(response.data);

      if (response.statusCode == 200) {
        String fileUrl = response.data["secure_url"];

        final profile = await fetchProfile();
        if (profile == null) {
          setState(
            () => _result =
                "Error: Could not fetch user profile to complete request.",
          );
          return;
        }

        var flaskResponse = await http.post(
          Uri.parse(
            "https://campusnest-ml-api.onrender.com/resume",
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"resume": fileUrl, "userId": profile["id"], "resume_name": _resumeName ?? ""}),
        );

        if (flaskResponse.statusCode == 200) {
          setState(() {
            _result = "Success! Resume uploaded and sent for analysis. 🎉";
          });
          await Future.delayed(const Duration(seconds: 3));
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          setState(
            () => _result =
                "Error: Failed to notify analysis server: ${flaskResponse.body}",
          );
        }
      } else {
        setState(
          () => _result =
              "Error: Cloudinary upload failed with status ${response.statusCode}.",
        );
      }
    } catch (e) {
      setState(() {
        _result = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // --- New Styled UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildContentCard(),
                ),
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
            icon: Icon(Icons.arrow_back, color: darkColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            'Upload & Analyze',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    bool isError =
        _result != null && _result!.toLowerCase().startsWith('error');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_file_rounded,
                color: primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Your Resume',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your PDF resume to extract skills and prepare your profile for job applications.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: grayColor,
                height: 1.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  'Resume Name',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkColor,
                  ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                  onChanged: (value) {
                    setState(() {
                    _resumeName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter a placeholder name for your resume',
                    hintStyle: GoogleFonts.montserrat(color: grayColor),
                    prefixIcon: Icon(Icons.person, color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.montserrat(color: darkColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _pickAndUploadResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: lightColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: lightColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Uploading...',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Choose PDF to Upload',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isError
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: isError
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
