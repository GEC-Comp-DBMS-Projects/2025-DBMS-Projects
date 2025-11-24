import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/student_screens/application_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;

  const JobDetailsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);
  final Color lightTeal = const Color(0xFFEBFBFA);

  bool isLoading = true;
  Map<String, dynamic>? jobDetails;
  bool isApplying = false;
  bool isBookmarked = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fetchJobDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightTeal, primaryColor, darkColor],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(lightColor),
                  ),
                )
              : jobDetails == null
                  ? _buildErrorState()
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              children: [
                                _buildHeroCard(),
                                _buildQuickInfoCards(),
                                _buildDescriptionCard(),
                                _buildRequirementsCard(),
                                _buildSkillsCard(),
                              ],
                            ),
                          ),
                        ),
                        _buildApplyButton(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: darkColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Job Details',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: darkColor,
              ),
              onPressed: () {
                setState(() {
                  isBookmarked = !isBookmarked;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return _buildAnimatedCard(
      0,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, darkColor],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: darkColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getCompanyInitial(),
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              jobDetails!['title'] ?? 'Job Title',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              jobDetails!['company'] ?? 'Company Name',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,
                    color: Colors.white.withOpacity(0.9), size: 18),
                const SizedBox(width: 6),
                Text(
                  jobDetails!['location'] ?? 'Location',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    final deadline = DateTime.tryParse(jobDetails!['deadline'] ?? '');
    final daysLeft = deadline?.difference(DateTime.now()).inDays ?? 0;
    final isUrgent = daysLeft <= 7 && daysLeft >= 0;

    return _buildAnimatedCard(
      0.1,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildInfoMetricCard(
                Icons.attach_money,
                'Salary',
                jobDetails!['salary'] ?? '₹Not specified',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoMetricCard(
                Icons.work_outline,
                'Openings',
                '${jobDetails!['openings'] ?? 0}',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoMetricCard(
                isUrgent ? Icons.access_time : Icons.calendar_today,
                'Deadline',
                deadline != null
                    ? (isUrgent
                        ? '$daysLeft days'
                        : DateFormat('d MMM').format(deadline))
                    : 'N/A',
                isUrgent ? Colors.orange : Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMetricCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: grayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildAnimatedCard(
      0.2,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Job Description',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                jobDetails!['description'] ?? 'No description available.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: darkColor.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return _buildAnimatedCard(
      0.3,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_outlined, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Eligibility Requirements',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                jobDetails!['requirements'] ?? 'No requirements specified.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: darkColor.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    if (jobDetails!['skills'] == null || 
        (jobDetails!['skills'] is List && (jobDetails!['skills'] as List).isEmpty)) {
      return const SizedBox.shrink();
    }

    List<String> skills = [];
    if (jobDetails!['skills'] is String) {
      skills = jobDetails!['skills'].split(',').map((s) => s.trim()).toList();
    } else if (jobDetails!['skills'] is List) {
      skills = List<String>.from(jobDetails!['skills']);
    }

    if (skills.isEmpty) return const SizedBox.shrink();

    return _buildAnimatedCard(
      0.4,
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Skills Required',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    final bool hasApplied = jobDetails?['applied'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isApplying || hasApplied) ? null : _navigateToApplyPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: grayColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
            ),
            child: isApplying
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : hasApplied
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Already Applied',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Apply Now',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(double delay, Widget child) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: lightColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.error_outline, size: 64, color: lightColor),
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to Load',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: lightColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Could not fetch job details',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: lightColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: fetchJobDetails,
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightColor,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCompanyInitial() {
    String company = jobDetails!['company'] ?? 'C';
    return company.isNotEmpty ? company[0].toUpperCase() : 'C';
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  String _formatEligibility(Map<String, dynamic>? eligibility) {
    if (eligibility == null) return 'No requirements specified.';
    return '''
Min CGPA: ${eligibility['min_cgpa'] ?? '-'}
Course: ${(eligibility['course'] as List?)?.join(', ') ?? '-'}
Max Backlogs: ${eligibility['max_backlogs'] ?? '-'}
Graduation Year: ${eligibility['graduation_year'] == 0 ? '-' : eligibility['graduation_year']}
''';
  }

  Future<void> fetchJobDetails() async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs/${widget.jobId}',
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
        print(data);

        setState(() {
          jobDetails = {
            'ID': data['job']['id'],
            'title': data['job']['position'],
            'company': data['job']['company_name']?['name'] ?? '',
            'location': data['job']['location'] ?? 'Not specified',
            'salary': data['job']['salary_range'].isEmpty
                ? '₹Not specified'
                : data['job']['salary_range'],
            'deadline': data['job']['application_deadline'] ?? 'Not specified',
            'description': data['job']['description']?.isEmpty ?? true
                ? 'No description available.'
                : data['job']['description'],
            'requirements': _formatEligibility(data['job']['eligibility']),
            'skills': data['job']['eligibility']?['skills'] ?? [],
            'openings': data['job']['openings'] ?? 10,
            'type': 'Full-time',
            'applied': data['has_applied'] ?? false,
          };
          isLoading = false;
        });
        _animationController.forward();
      } else {
        print('Failed to load job details: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching job details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToApplyPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ApplicationPreviewPage(
        jobId: jobDetails!['ID'], 
      ),
    ),
  );
}

  // Future<void> _applyForJob() async {
  //   setState(() {
  //     isApplying = true;
  //   });

  //   final token = await getToken();
  //   if (token.isEmpty) {
  //     print('No token found');
  //     setState(() {
  //       isApplying = false;
  //     });
  //     return;
  //   }

  //   final url = Uri.parse(
  //     'https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs/${widget.jobId}/apply',
  //   );

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               const SizedBox(width: 12),
  //               Text(
  //                 'Application submitted successfully!',
  //                 style: GoogleFonts.montserrat(),
  //               ),
  //             ],
  //           ),
  //           backgroundColor: primaryColor,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           margin: const EdgeInsets.all(16),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.error, color: Colors.white),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   'Failed to submit application',
  //                   style: GoogleFonts.montserrat(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           backgroundColor: Colors.red[600],
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           margin: const EdgeInsets.all(16),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error applying for job: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Icon(Icons.error, color: Colors.white),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 'An error occurred',
  //                 style: GoogleFonts.montserrat(),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: Colors.red[600],
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       isApplying = false;
  //     });
  //   }
  // }
}