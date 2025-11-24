import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/tpo_screens/app_screen.dart';
import 'package:frontend/tpo_screens/jobs_mng_screen.dart';
import 'package:frontend/tpo_screens/stud_list_screen.dart';
import 'package:frontend/tpo_screens/tpoProfile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../custom_header.dart';

class TPODashboardScreen extends StatefulWidget {
  const TPODashboardScreen({super.key});

  @override
  State<TPODashboardScreen> createState() => _TPODashboardScreenState();
}

class _TPODashboardScreenState extends State<TPODashboardScreen> {
  int _selectedIndex = 0;

  final Color primaryColor = const Color(0xFF5D9493);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFF9E9E9E);

  bool isLoading = false;
  Map<String, dynamic> dashboardData = {};

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    _screens = [
      const Center(child: CircularProgressIndicator()),
      const Center(child: Text("Jobs Management")),
      const Center(child: Text("Analytics")),
      const Center(child: Text("Students")),
      const Center(child: Text("Profile")),
    ];

    fetchData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    final role = await getRole();

    if (token.isEmpty) {
      print('No token found');
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/dashboard/$role',
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
        print('Dashboard data: $data');

        setState(() {
          final overview = data['overview'] ?? {};
          final appStats = data['applicationStats'] ?? {};
          final placementData = data['placementRateByDepartment'] ?? [];
          final activities = data['recentActivities'] ?? [];
          final quickActions = data['quickActions'] ?? [];

          dashboardData = {
            'userName': data['userName'] ?? 'TPO',
            'overview': {
              'totalStudents': overview['totalStudents'] ?? 0,
              'activeDrives': overview['activeDrives'] ?? 0,
              'companies': overview['companiesOnboarded'] ?? 0,
            },
            'applicationStats': {
              'totalApplications': appStats['totalApplications'] ?? 0,
              'shortlistedToday': appStats['shortlistedStudents'] ?? 0,
              'offersReleased': appStats['offersReleased'] ?? 0,
            },
            'placementRateByDepartment': placementData,
            'recentActivities': activities,
            'quickActions': quickActions,
          };

          _screens = [
            _DashboardHome(
              primaryColor: primaryColor,
              darkColor: darkColor,
              dashboardData: dashboardData,
            ),
            JobsManagementScreen(),
            TpoAnalyticsScreen(),
            StudentsListScreen(),
            TPOProfileScreen(),
          ];

          isLoading = false;
        });
      } else {
        print('Failed to load dashboard: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
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
            color: darkColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(Icons.work_outline, 'Jobs', 1),
          _buildNavItem(Icons.bar_chart, 'Stats', 2),
          _buildNavItem(Icons.group_outlined, 'Students', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isSelected ? primaryColor : grayColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: isSelected ? primaryColor : grayColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
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
              child: Column(
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
                      ),
                    },
                  ),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: lightColor),
                          )
                        : IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final Color primaryColor;
  final Color darkColor;
  final Map<String, dynamic> dashboardData;

  const _DashboardHome({
    required this.primaryColor,
    required this.darkColor,
    required this.dashboardData,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'shortlisted':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'accepted':
      case 'offered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Icons.send;
      case 'shortlisted':
        return Icons.star;
      case 'rejected':
        return Icons.cancel;
      case 'accepted':
      case 'offered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = dashboardData['overview'] ?? {};
    final appStats = dashboardData['applicationStats'] ?? {};
    final placementData = dashboardData['placementRateByDepartment'] ?? [];
    final recentActivities = dashboardData['recentActivities'] ?? [];
    final userName = dashboardData['userName'] ?? 'TPO';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, darkColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Placement Dashboard - $userName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Manage placements, track applications, and monitor student progress",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Students",
                  value: "${overview['totalStudents'] ?? 0}",
                  icon: Icons.group,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Active Drives",
                  value: "${overview['activeDrives'] ?? 0}",
                  icon: Icons.business,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Companies",
                  value: "${overview['companies'] ?? 0}",
                  icon: Icons.apartment,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
            Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
                ),
              ],
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                children: [
                  Icon(Icons.analytics, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                  "Live Application Statistics",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                  ),
                ],
                ),
                const SizedBox(height: 16),
                _ApplicationStatRow(
                "Total Applications:",
                "${appStats['totalApplications'] ?? 0}",
                ),
                const SizedBox(height: 12),
                _ApplicationStatRow(
                "Shortlisted Students:",
                "${appStats['shortlistedToday'] ?? 0}",
                ),
                const SizedBox(height: 12),
                _ApplicationStatRow(
                "Offers Released:",
                "${appStats['offersReleased'] ?? 0}",
                ),
              ],
              ),
            ),
            ),
          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      "Placement Rate by Department",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (placementData.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No placement data available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...placementData.map<Widget>((dept) {
                    final deptName = dept['department'] ?? 'Unknown';
                    final rate = (dept['placementRate'] ?? 0).toDouble();
                    final placed = dept['placedStudents'] ?? 0;
                    final total = dept['totalStudents'] ?? 0;

                    // Assign colors based on department
                    Color deptColor;
                    if (deptName.toLowerCase().contains('computer')) {
                      deptColor = Colors.blue;
                    } else if (deptName.toLowerCase().contains('mechanical')) {
                      deptColor = Colors.green;
                    } else if (deptName.toLowerCase().contains('electronics')) {
                      deptColor = Colors.orange;
                    } else if (deptName.toLowerCase().contains('civil')) {
                      deptColor = Colors.purple;
                    } else {
                      deptColor = Colors.teal;
                    }

                    return _DepartmentPlacementRow(
                      deptName,
                      rate.toInt(),
                      deptColor,
                      placed,
                      total,
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Recent Activities",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentActivities.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No recent activities",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...recentActivities.take(5).map<Widget>((activity) {
                    final studentName = activity['studentName'] ?? 'Unknown';
                    final companyName = activity['companyName'] ?? 'Unknown';
                    final position = activity['position'] ?? 'Position';
                    final status = activity['status'] ?? 'applied';
                    final appliedOn = activity['appliedOn'] ?? '';

                    return _ActivityItem(
                      "$studentName applied for $position",
                      "$companyName - Status: ${status.toUpperCase()}",
                      _formatDate(appliedOn),
                      _getStatusIcon(status),
                      _getStatusColor(status),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ApplicationStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _ApplicationStatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentPlacementRow extends StatelessWidget {
  final String department;
  final int percentage;
  final Color color;
  final int placedStudents;
  final int totalStudents;

  const _DepartmentPlacementRow(
    this.department,
    this.percentage,
    this.color,
    this.placedStudents,
    this.totalStudents,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                department,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$percentage% ($placedStudents/$totalStudents)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem(
    this.title,
    this.subtitle,
    this.time,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
