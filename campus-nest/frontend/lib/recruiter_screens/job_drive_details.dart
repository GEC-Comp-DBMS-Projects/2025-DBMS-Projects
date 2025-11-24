import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDriveDetailsPage extends StatefulWidget {
  final String jobId;
  const JobDriveDetailsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDriveDetailsPage> createState() => _JobDriveDetailsPageState();
}

class _JobDriveDetailsPageState extends State<JobDriveDetailsPage> with SingleTickerProviderStateMixin {

  bool _isLoading = true;
  Map<String, dynamic>? _jobDriveData;
  List<dynamic> _candidates = [];
  Map<String, dynamic>? _statistics;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchJobDriveDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchJobDriveDetails() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives/${widget.jobId}');
    
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        print('Job Drive Details Response: ${response.body}');
        setState(() {
          _jobDriveData = data['jobDrive'];
          _candidates = data['candidates'] ?? [];
          _statistics = data['statistics'];
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showApplicantDetails(String studentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => _ApplicantDetailsSheet(
            jobId: widget.jobId,
            studentId: studentId,
            scrollController: controller,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CustomPallete.lightTeal, CustomPallete.primaryColor, CustomPallete.darkColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: CustomPallete.lightColor, strokeWidth: 3),
                            const SizedBox(height: 16),
                            Text("Loading job details...", style: GoogleFonts.montserrat(color: CustomPallete.lightColor)),
                          ],
                        ),
                      )
                    : _jobDriveData == null
                        ? _buildErrorState()
                        : _buildDetailsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CustomPallete.darkColor.withOpacity(0.3), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: CustomPallete.lightColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: CustomPallete.lightColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobDriveData?['position'] ?? 'Job Details',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomPallete.lightColor,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_jobDriveData != null)
                  Text(
                    _jobDriveData?['company']?['Name'] ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: CustomPallete.lightColor.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: CustomPallete.lightColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomPallete.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 64, color: CustomPallete.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              "Job drive not found",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CustomPallete.darkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This job drive may have been removed",
              style: GoogleFonts.montserrat(color: CustomPallete.grayColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: _buildInfoCard(),
          ),
        ),
        const SizedBox(height: 16),
        if (_statistics != null)
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
              )),
              child: _buildStatisticsCard(),
            ),
          ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
            )),
            child: _buildApplicantsCard(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomPallete.darkColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business_rounded, color: CustomPallete.lightColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: CustomPallete.grayColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _jobDriveData?['company']?['Name'] ?? 'Company',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CustomPallete.darkColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _infoRow(Icons.location_on_outlined, 'Location', _jobDriveData?['location'] ?? 'N/A'),
          _infoRow(Icons.attach_money_outlined, 'Salary Range', _jobDriveData?['salary_range'] ?? 'N/A'),
          _infoRow(Icons.school_outlined, 'Minimum CGPA', '${_jobDriveData?['eligibility']?['min_cgpa'] ?? 'N/A'}'),
          _infoRow(
            Icons.event_outlined,
            'Application Deadline',
            DateFormat('d MMMM yyyy').format(DateTime.parse(_jobDriveData?['application_deadline'])),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomPallete.darkColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: CustomPallete.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Application Statistics',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomPallete.darkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _statTile('Total', _statistics!['totalApplications']?.toString() ?? '0', Icons.people_rounded, CustomPallete.primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: _statTile('Shortlisted', _statistics!['shortlisted']?.toString() ?? '0', Icons.star_rounded, Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statTile('Selected', _statistics!['selected']?.toString() ?? '0', Icons.check_circle_rounded, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _statTile('Rejected', _statistics!['rejected']?.toString() ?? '0', Icons.cancel_rounded, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomPallete.darkColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.group_outlined, color: CustomPallete.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Candidates',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CustomPallete.darkColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CustomPallete.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_candidates.length}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: CustomPallete.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_candidates.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: CustomPallete.grayColor.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      "No applications yet",
                      style: GoogleFonts.montserrat(
                        color: CustomPallete.grayColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._candidates.asMap().entries.map((entry) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (entry.key * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _applicantTile(entry.value),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _applicantTile(Map<String, dynamic> candidate) {
    final student = candidate['student'];
    if (student == null) return const SizedBox.shrink();

    final status = candidate['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () => _showApplicantDetails(student['_id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomPallete.grayColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                gradient: LinearGradient(
                  colors: [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CustomPallete.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (student['firstName']?[0] ?? '?').toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                    "${student['firstName']} ${student['lastName']}",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: CustomPallete.darkColor,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(status), size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: GoogleFonts.montserrat(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.school_outlined, size: 14, color: CustomPallete.grayColor),
                      const SizedBox(width: 4),
                      Flexible( 
                        child: Text(
                          student['department'] ?? 'N/A',
                          style: GoogleFonts.montserrat(color: CustomPallete.grayColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, size: 14, color: CustomPallete.grayColor),
                      const SizedBox(width: 4),
                      Text(
                        "CGPA: ${student['cgpa'] ?? 'N/A'}",
                        style: GoogleFonts.montserrat(color: CustomPallete.grayColor, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: CustomPallete.darkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: CustomPallete.grayColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow(IconData icon, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomPallete.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CustomPallete.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: CustomPallete.grayColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                    color: CustomPallete.darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'selected': return Colors.green;
      case 'applied':
      default:
        return CustomPallete.primaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted': return Icons.star_rounded;
      case 'rejected': return Icons.close_rounded;
      case 'selected': return Icons.check_circle_rounded;
      case 'applied':
      default:
        return Icons.send_rounded;
    }
  }
}

class _ApplicantDetailsSheet extends StatefulWidget {
  final String jobId;
  final String studentId;
  final ScrollController scrollController;

  const _ApplicantDetailsSheet({
    required this.jobId,
    required this.studentId,
    required this.scrollController,
  });

  @override
  State<_ApplicantDetailsSheet> createState() => _ApplicantDetailsSheetState();
}

class _ApplicantDetailsSheetState extends State<_ApplicantDetailsSheet> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _details;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fetchApplicantDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchApplicantDetails() async {
    final token = await SharedPreferences.getInstance().then((p) => p.getString('auth_token') ?? '');
    if (token.isEmpty) {
      if(mounted) setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives/${widget.jobId}/students/${widget.studentId}');
    
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      print('Applicant Details Response: ${response.body}');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _details = jsonDecode(response.body);
          _isLoading = false;
        });
        _fadeController.forward();
      } else {
         if(mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomPallete.lightColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: CustomPallete.grayColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: CustomPallete.primaryColor, strokeWidth: 3),
                        const SizedBox(height: 16),
                        Text("Loading profile...", style: GoogleFonts.montserrat(color: CustomPallete.grayColor)),
                      ],
                    ),
                  )
                : _details == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 64, color: CustomPallete.grayColor),
                            const SizedBox(height: 16),
                            Text(
                              "Could not load applicant details",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CustomPallete.darkColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeController,
                        child: _buildDetailsList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    final studentDetails = _details?['studentDetails'];
    if (studentDetails == null) return const Center(child: Text("No data found."));
    
    final student = studentDetails['student'];
    final application = studentDetails['application'];
    final otherApplications = studentDetails['otherApplications'] as List<dynamic>? ?? [];
    final List<dynamic> skills = student['skills'] ?? [];

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomPallete.primaryColor, CustomPallete.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CustomPallete.primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (student['firstName']?[0] ?? '?').toUpperCase(),
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${student['firstName']} ${student['lastName']}",
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: CustomPallete.darkColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student['department'] ?? 'N/A',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: CustomPallete.grayColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: _infoChip("CGPA: ${student['cgpa']}", Icons.stars_rounded, CustomPallete.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _infoChip("Status: ${application['status']}", Icons.flag_outlined, _getStatusColor(application['status']))),
          ],
        ),
        const SizedBox(height: 32),

        _buildSectionHeader('Skills & Expertise', Icons.lightbulb_outline_rounded),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomPallete.grayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "No skills listed",
                style: GoogleFonts.montserrat(color: CustomPallete.grayColor),
              ),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomPallete.primaryColor.withOpacity(0.15), CustomPallete.primaryColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CustomPallete.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                skill.toString(),
                style: GoogleFonts.montserrat(
                  color: CustomPallete.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )).toList(),
          ),
        const SizedBox(height: 32),
        
        _buildSectionHeader('Documents', Icons.description_outlined),
        const SizedBox(height: 16),
        InkWell(
          onTap: () { 
            final resumeUrl = student['resume'];
            if (resumeUrl != null && resumeUrl.isNotEmpty) {
              launchUrl(Uri.parse(resumeUrl));
            } else {
              AppToast.error(context, 'Resume not available.');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomPallete.primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: CustomPallete.primaryColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Resume",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: CustomPallete.darkColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tap to view PDF",
                        style: GoogleFonts.montserrat(
                          color: CustomPallete.grayColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: CustomPallete.primaryColor, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Application History', Icons.history_rounded, subtitle: '${otherApplications.length} other applications'),
        const SizedBox(height: 16),
        if (otherApplications.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomPallete.grayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "No other applications found",
                style: GoogleFonts.montserrat(color: CustomPallete.grayColor),
              ),
            ),
          )
        else
          ...otherApplications.map((app) => _buildOtherApplicationTile(app)),

        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon, {String? subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomPallete.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: CustomPallete.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomPallete.darkColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: CustomPallete.grayColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherApplicationTile(Map<String, dynamic> app) {
    final job = app['job'];
    final status = app['status'];
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomPallete.grayColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CustomPallete.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline_rounded, color: CustomPallete.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['position'],
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: CustomPallete.darkColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job['company_name']['name'],
                  style: GoogleFonts.montserrat(
                    color: CustomPallete.grayColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: GoogleFonts.montserrat(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'selected': return Colors.green;
      case 'applied':
      default:
        return CustomPallete.primaryColor;
    }
  }
  
  Widget _infoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                color: CustomPallete.darkColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}