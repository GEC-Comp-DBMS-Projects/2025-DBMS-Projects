import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/recruiter_screens/recruiter_appl.dart';
import 'package:frontend/recruiter_screens/recruiter_drives.dart';
import 'package:frontend/recruiter_screens/recruiter_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  Map<String, dynamic> dashboardData = {};
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? '';
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final token = await getToken();
    final role = await getRole();

    if (token.isEmpty) {
      debugPrint('No token found');
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/dashboard/$role');

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
        debugPrint('Data: $data');

        setState(() {
          dashboardData = data;
          isLoading = false;
        });
      } else {
        debugPrint('Failed to load data: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppHeader(
            onProfileTap: () => setState(() => _selectedIndex = 4),
            primaryColor: CustomPallete.primaryColor,
            darkColor: CustomPallete.darkColor,
            lightColor: CustomPallete.lightColor,
            onNotificationTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              )
            },
          ),
          const SizedBox(height: 20),
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      child: _buildStatCard(
        'Total Job\nPostings',
        dashboardData['overview']?['totalJobDrives']?.toString() ?? '0',
        Icons.work_outline,
        const Color(0xFF3498DB),
      ),
    ),
    SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      child: _buildStatCard(
        'Total Application',
        dashboardData['overview']?['totalApplications']?.toString() ?? '0',
        Icons.description_outlined,
        const Color(0xFFE74C3C),
      ),
    ),
    SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      child: _buildStatCard(
        'Shortlisted\nby You',
        dashboardData['overview']?['totalShortlisted']?.toString() ?? '0',
        Icons.check_circle_outline,
        const Color(0xFF27AE60),
      ),
    ),
  ],
),

          const SizedBox(height: 20),
          _buildCompanyStats(),
          const SizedBox(height: 20),
          _buildRecentJobDrives(),
          const SizedBox(height: 20),
          _buildRecentActivities(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [CustomPallete.primaryColor, CustomPallete.darkColor],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CustomPallete.darkColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -15,
                left: -5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.waving_hand,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome Back, ${dashboardData['recruiterName'] ?? 'Recruiter'}!',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CustomPallete.lightColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Track your placement journey and discover new opportunities',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: CustomPallete.lightColor.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active Status',
                              style: GoogleFonts.montserrat(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Statistics',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Applications:',
            dashboardData['overview']?['totalApplications']?.toString() ?? '0',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Active Job Drives:',
            dashboardData['overview']?['activeJobDrives']?.toString() ?? '0',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Total Shortlisted:',
            dashboardData['overview']?['totalShortlisted']?.toString() ?? '0',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentJobDrives() {
    final recentJobDrives = dashboardData['recentJobDrives'] as List? ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Job Drives',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...recentJobDrives.take(3).map((jobDrive) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF5A8B8E),
                  child: const Icon(
                    Icons.work,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobDrive['position'] ?? 'Unknown Position',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${jobDrive['status'] ?? 'Unknown'}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${jobDrive['totalApplications'] ?? 0} Apps',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (recentJobDrives.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No job drives yet',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _selectedIndex = 1);
            },
            child: Text(
              'View All →',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A8B8E),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = dashboardData['recentActivities'] as List? ?? [];
    
    final defaultActivities = [
      {
        'title': 'New application received for Software Engineer',
        'time': '2 hours ago',
        'type': 'application'
      },
      {
        'title': 'Interview scheduled for Data Analyst position',
        'time': '1 day ago', 
        'type': 'interview'
      },
      {
        'title': 'Candidate shortlisted for Product Manager role',
        'time': '2 days ago',
        'type': 'shortlist'
      }
    ];
    
    final displayActivities = activities.isEmpty ? defaultActivities : activities;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 20, color: Color(0xFF5A8B8E)),
              const SizedBox(width: 8),
              Text(
                'Recent Activities',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayActivities.take(3).map((activity) {
            return _buildActivityItem(
              activity['title'] ?? '',
              activity['time'] ?? '',
              _getActivityIcon(activity['type']),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'interview':
        return Icons.event;
      case 'shortlist':
        return Icons.check_circle_outline;
      case 'offer':
        return Icons.description_outlined;
      case 'application':
        return Icons.assignment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5A8B8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF5A8B8E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  if (isLoading) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CustomPallete.lightTeal, CustomPallete.primaryColor, CustomPallete.darkColor],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5A8B8E),
        ),
      ),
    );
  }

  final List<Widget> pages = [
    _buildDashboardContent(),
    const RecruiterDrivesScreen(),
    const RecruiterApplicationsScreen(),
    const RecruiterProfileScreen(),
  ];

  return Scaffold(
  backgroundColor: Colors.transparent,
  body: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CustomPallete.lightTeal,
          CustomPallete.primaryColor,
          CustomPallete.darkColor,
        ],
      ),
    ),
    child: SafeArea(
      child: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: CustomPallete.darkColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(Icons.work_outline, 'Job Drives', 1),
          _buildNavItem(Icons.description_outlined, 'Applications', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected
                ? CustomPallete.primaryColor
                : CustomPallete.grayColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: isSelected
                  ? CustomPallete.primaryColor
                  : CustomPallete.grayColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
