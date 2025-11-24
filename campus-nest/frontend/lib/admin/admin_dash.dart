import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/admin/admin_profile.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class TpoManagementScreen extends StatelessWidget {
  const TpoManagementScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text("TPO Management Screen"));
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  final List<Widget> _screens = [
    const _DashboardHome(), // The main dashboard content
    const TpoManagementScreen(),
    const Center(child: Text("Students Overview")),
    const AdminProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboardData();
  }
  
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- API Logic ---
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchAdminDashboardData() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/admin/dashboard');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _dashboardData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _screens[0] = _DashboardHome(dashboardData: _dashboardData);

    return Scaffold(
      backgroundColor: lightColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // The CustomAppHeader would be consistent across the app
                // For simplicity, we'll build a simple header here.
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : IndexedStack(
                          index: _selectedIndex,
                          children: _screens,
                        ),
                ),
              ],
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
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: darkColor),
              ),
              Text(
                'Welcome, Head TPO!',
                style: GoogleFonts.montserrat(fontSize: 16, color: grayColor),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF616161)),
          )
        ],
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
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(Icons.supervised_user_circle_outlined, 'TPOs', 1),
          _buildNavItem(Icons.school_outlined, 'Students', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
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
}


/// --- Main Dashboard Content Widget ---
class _DashboardHome extends StatelessWidget {
  final Map<String, dynamic> dashboardData;
  const _DashboardHome({this.dashboardData = const {}});

  final Color primaryColor = const Color(0xFF5D9493);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      child: Column(
        children: [
          _buildKeyMetrics(),
          const SizedBox(height: 20),
          _buildTpoPerformanceChart(),
          const SizedBox(height: 20),
          _buildStudentDistributionChart(),
          // Add other charts like recent activities if needed
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final overview = dashboardData['overview'] ?? {};
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _StatCard(title: 'Total TPOs', value: overview['totalTPOs']?.toString() ?? '0', icon: Icons.supervised_user_circle, color: primaryColor),
        _StatCard(title: 'Total Students', value: overview['totalStudents']?.toString() ?? '0', icon: Icons.school, color: Colors.orange),
        _StatCard(title: 'Companies', value: overview['totalCompanies']?.toString() ?? '0', icon: Icons.business, color: Colors.deepPurple),
        _StatCard(title: 'Placement Rate', value: '${(overview['overallPlacementRate'] ?? 0.0).toStringAsFixed(1)}%', icon: Icons.trending_up, color: Colors.green),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: darkColor)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildTpoPerformanceChart() {
    final tpoPerformance = dashboardData['tpoPerformance'] as List? ?? [];
    return _buildChartCard(
      title: "Placement Rate by TPO",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: tpoPerformance.asMap().entries.map((entry) {
            return BarChartGroupData(x: entry.key, barRods: [
              BarChartRodData(
                toY: (entry.value['placementRate'] ?? 0).toDouble(),
                color: primaryColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )
            ]);
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              return Text(tpoPerformance[value.toInt()]['name'] ?? '', style: GoogleFonts.montserrat(fontSize: 10));
            }, reservedSize: 30)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v,m) => Text('${v.toInt()}%'))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (v) => FlLine(color: grayColor.withOpacity(0.2))),
        ),
      ),
    );
  }

  Widget _buildStudentDistributionChart() {
    final departments = dashboardData['studentDistributionByDepartment'] as List? ?? [];
    return _buildChartCard(
      title: "Student Distribution",
      child: PieChart(
        PieChartData(
          sections: departments.asMap().entries.map((entry) {
            final color = [primaryColor, Colors.blue, Colors.orange, Colors.deepPurple][entry.key % 4];
            return PieChartSectionData(
              color: color,
              value: (entry.value['count'] ?? 0).toDouble(),
              title: '${entry.value['department']}\n${entry.value['count']}',
              radius: 80,
              titleStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              titlePositionPercentageOffset: 0.55,
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title; final String value; final IconData icon; final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF21464E))),
          Text(title, style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFFA1B5B7), height: 1.3)),
        ],
      ),
    );
  }
}