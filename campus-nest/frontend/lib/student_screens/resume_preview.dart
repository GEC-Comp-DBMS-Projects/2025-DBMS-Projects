import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../loader.dart'; // Import your custom loader
import '../toast.dart'; // Import your custom toast

class ResumeReviewPage extends StatefulWidget {
  final String resumeId;
  final String resumeFileUrl;

  const ResumeReviewPage({
    Key? key,
    required this.resumeId,
    required this.resumeFileUrl,
  }) : super(key: key);

  @override
  State<ResumeReviewPage> createState() => _ResumeReviewPageState();
}

class _ResumeReviewPageState extends State<ResumeReviewPage> {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool _isLoading = true;
  Map<String, dynamic>? _analysisResult;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchAnalysis() async {
    setState(() => _isLoading = true);
    final token = await _getToken();

    print("--- Fetching analysis for Resume ID: ${widget.resumeId} --- ${widget.resumeFileUrl}");
    
    final url = Uri.parse("https://campusnest-ml-api.onrender.com/api/v1/student/resume/analyze");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'resumeId': widget.resumeId, 'fileUrl': widget.resumeFileUrl}),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _analysisResult = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Failed to load analysis";
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An error occurred: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightColor, primaryColor, darkColor],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? CustomLoader(
                      primaryColor: primaryColor,
                      darkColor: darkColor,
                      lightColor: lightColor,
                      loadingText: "Analyzing Resume...",
                    )
                  : _analysisResult != null
                      ? _buildResults()
                      : _buildErrorState(),
            ),
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
              icon: Icon(Icons.arrow_back, color: darkColor),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Resume Review',
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: darkColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text("Analysis Failed", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
            const SizedBox(height: 8),
            Text(_errorMessage, style: GoogleFonts.montserrat(fontSize: 14, color: grayColor), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAnalysis,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text("Retry", style: GoogleFonts.montserrat(color: lightColor)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final int atsScore = _analysisResult?['atsScore'] ?? 0;
    final List<dynamic> suggestions = _analysisResult?['suggestions'] ?? [];
    final List<dynamic> missingKeywords = _analysisResult?['missingKeywords'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          _buildAtsScoreCard(atsScore),
          const SizedBox(height: 20),
          _buildSuggestionsCard("Suggestions", suggestions, Icons.lightbulb_outline, Colors.orange),
          const SizedBox(height: 20),
          _buildSuggestionsCard("Missing Keywords", missingKeywords, Icons.search_off_outlined, Colors.red),
        ],
      ),
    );
  }

  Widget _buildAtsScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 10,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  color: primaryColor,
                ),
                Center(
                  child: Text(
                    "$score%",
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: darkColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ATS Score",
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "This score estimates how well your resume will pass through automated tracking systems.",
                  style: GoogleFonts.montserrat(fontSize: 14, color: grayColor, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionsCard(String title, List<dynamic> items, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
              ),
            ],
          ),
          const Divider(height: 32),
          if (items.isEmpty)
            Text("No items found.", style: GoogleFonts.montserrat(color: grayColor))
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                    child: Icon(Icons.circle, size: 8, color: grayColor),
                  ),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: GoogleFonts.montserrat(fontSize: 14, color: darkColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }
}