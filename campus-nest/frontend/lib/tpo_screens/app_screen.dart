import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class TpoAnalyticsScreen extends StatefulWidget {
  const TpoAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<TpoAnalyticsScreen> createState() => _TpoAnalyticsScreenState();
}

class _TpoAnalyticsScreenState extends State<TpoAnalyticsScreen> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _fetchAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchAnalytics() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/tpo/analytics');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        print('Analytics Response: ${response.body}');
        setState(() {
          _analyticsData = jsonDecode(response.body);
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

@override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _analyticsData.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(opacity: _fadeAnimation, child: _buildAnalyticsContent()),
          ),
        ],
      ),
    );
  }

 Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: SafeArea(
    bottom: false,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
      'Placement Analytics',
      style: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkColor,
      ),
      ),
    ),
    ),
  );
  }

  Widget _buildLoadingState() {
  return Center(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
      const SizedBox(height: 16),
      Text("Loading analytics...", style: GoogleFonts.montserrat(color: darkColor)),
    ],
    ),
  );
  }

  Widget _buildEmptyState() {
  return Center(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.analytics_outlined, size: 64, color: grayColor.withOpacity(0.5)),
      ),
      const SizedBox(height: 24),
      Text(
      "No analytics data available",
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      ),
      const SizedBox(height: 8),
      Text(
      "Analytics will appear once data is collected",
      style: GoogleFonts.montserrat(color: grayColor),
      ),
    ],
    ),
  );
  }

  Widget _buildAnalyticsContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
    child: Column(
    children: [
      _buildKeyMetrics(),
      const SizedBox(height: 20),
      _buildApplicationSuccessChart(),
      const SizedBox(height: 20),
      _buildStudentShareChart(),
      const SizedBox(height: 20),
      _buildBatchTrendsChart(),
      const SizedBox(height: 20),
      _buildTopSkillsChart(),
    ],
    ),
  );
  }

  Widget _buildChartCard({required String title, required Widget chart, IconData? icon}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
      color: darkColor.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
      )
    ],
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
      children: [
        if (icon != null) ...[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        ],
        Expanded(
        child: Text(
          title,
          style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkColor,
          ),
        ),
        ),
      ],
      ),
      const SizedBox(height: 28),
      SizedBox(height: 200, child: chart),
    ],
    ),
  );
  }

  Widget _buildKeyMetrics() {
  final jobDrives = _analyticsData['jobDrives']?[0]?['jobDrives'] ?? 0;
  final departments = _analyticsData['departments'] as List? ?? [];
  final totalStudents = departments.fold<int>(0, (sum, dept) => sum + ((dept['total'] ?? 0) as int));
  final placedStudents = departments.fold<int>(0, (sum, dept) => sum + ((dept['placed'] ?? 0) as int));
  final placementRate = totalStudents > 0 ? (placedStudents / totalStudents * 100) : 0.0;
  final totalApplications = (_analyticsData['applicationSuccess'] as List? ?? []).fold<int>(0, (sum, item) => sum + ((item['applications'] ?? 0) as int));

  return GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    children: [
    _StatCard(title: 'Job Drives', value: jobDrives.toString(), icon: Icons.work_outline, color: primaryColor),
    _StatCard(title: 'Application', value: totalApplications.toString(), icon: Icons.description_outlined, color: Colors.orange),
    _StatCard(title: 'Placed', value: placedStudents.toString(), icon: Icons.check_circle_outline, color: Colors.green),
    _StatCard(title: 'Placement', value: '${placementRate.toStringAsFixed(1)}%', icon: Icons.trending_up, color: Colors.deepPurple),
    ],
  );
  }

  Widget _buildApplicationSuccessChart() {
  final List<dynamic> rawData = _analyticsData['applicationSuccess'] ?? [];
  final List<dynamic> data = rawData
    .where((item) => item != null && item['_id'] != null && (item['_id'] as String).trim().isNotEmpty)
    .toList();

  if (data.isEmpty) {
    return _buildChartCard(
    title: "Applications vs. Placed by Department",
    icon: Icons.bar_chart_rounded,
    chart: Center(
      child: Text(
      "No data",
      style: GoogleFonts.montserrat(color: grayColor),
      ),
    ),
    );
  }

  return _buildChartCard(
    title: "Applications vs. Placed by Department",
    icon: Icons.bar_chart_rounded,
    chart: BarChart(
    BarChartData(
      barTouchData: BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => darkColor,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
        if (groupIndex < 0 || groupIndex >= data.length) return null;
        final entry = data[groupIndex];
        final deptName = entry['_id'] ?? '';
        final isApplied = rod.color == primaryColor;
        final title = isApplied ? 'Applied' : 'Placed';
        return BarTooltipItem(
          '$deptName\n',
          GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
          children: [
          TextSpan(
            text: '$title: ${rod.toY.toInt()}',
            style: GoogleFonts.montserrat(color: rod.color),
          )
          ],
        );
        },
      ),
      ),
      alignment: BarChartAlignment.spaceAround,
      barGroups: data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final applications = (item['applications'] ?? 0).toDouble();
      final placed = (item['placed'] ?? 0).toDouble();
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(toY: applications, color: primaryColor, width: 15, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: placed, color: Colors.green, width: 15, borderRadius: BorderRadius.circular(4)),
      ]);
      }).toList(),
      titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
          String name = data[idx]['_id'] ?? 'N/A';
          if (name.toLowerCase().contains('comp')) name = 'CS';
          if (name.toLowerCase().contains('info')) name = 'IT';
          if (name.toLowerCase().contains('elec')) name = 'ETC';
          if (name.toLowerCase().contains('mech')) name = 'ME';
          return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            name,
            style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: darkColor),
          ),
          );
        },
        reservedSize: 32,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (v, m) => Text(v.toInt().toString()),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 5,
      getDrawingHorizontalLine: (v) => FlLine(color: grayColor.withOpacity(0.15)),
      ),
    ),
    ),
  );
  }
  
  Widget _buildStudentShareChart() {
  final List<dynamic> departments = _analyticsData['departments'] ?? [];
  return _buildChartCard(
    title: "Student Distribution by Department",
    icon: Icons.pie_chart_outline_rounded,
    chart: PieChart(
    PieChartData(
      sections: departments.asMap().entries.map((entry) {
      final index = entry.key;
      final dept = entry.value;
      final color = [primaryColor, secondaryColor, Colors.orange, Colors.deepPurple][index % 4];
      return PieChartSectionData(
        color: color,
        value: (dept['total'] ?? 0).toDouble(),
        title: '${dept['total']}',
        radius: 80,
        titleStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
      );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    ),
    ),
  );
  }

  Widget _buildBatchTrendsChart() {
  final List<dynamic> genderStats = _analyticsData['genderStats'] ?? [];
  return _buildChartCard(
    title: "Placement Trend by Gender",
    icon: Icons.pie_chart_outline_rounded,
    chart: genderStats.isEmpty
      ? Center(
        child: Text(
        "No data",
        style: GoogleFonts.montserrat(color: grayColor),
        ),
      )
      : PieChart(
        PieChartData(
        sections: genderStats.asMap().entries.map((entry) {
          final stat = entry.value;
          final label = (stat['_id'] as String?)?.toLowerCase() ?? 'other';
          final count = (stat['count'] ?? 0).toDouble();
          final total = genderStats.fold<double>(0, (s, it) => s + ((it['count'] ?? 0) as num).toDouble());
          final percentage = total > 0 ? (count / total * 100) : 0.0;
          final displayPerc = percentage.toStringAsFixed(1);
          final color = label.contains('female')
            ? darkColor
            : label.contains('male')
            ? primaryColor
            : Colors.orange;

          return PieChartSectionData(
          color: color,
          value: count,
          title: '$displayPerc%',
          radius: 80,
          titleStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          badgeWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
            ),
            child: Text(
            stat['_id'] ?? '',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            ),
          ),
          badgePositionPercentageOffset: 1.2,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 15,
        ),
      ),
  );
  }

  Widget _buildTopSkillsChart() {
  final List<dynamic> topSkills = _analyticsData['topSkills'] ?? [];
  return _buildChartCard(
    title: "Top In-Demand Skills",
    icon: Icons.lightbulb_rounded,
    chart: topSkills.isEmpty
      ? Center(
        child: Text(
        "No skill data",
        style: GoogleFonts.montserrat(color: grayColor),
        ),
      )
      : BarChart(
        BarChartData(
        barGroups: topSkills.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final skill = entry.value;
          return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
            toY: (skill['count'] ?? 0).toDouble(),
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.6)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 18,
            borderRadius: BorderRadius.circular(8),
            ),
          ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= 5 || index >= topSkills.length) {
              return const SizedBox.shrink();
            }
            final fullName = topSkills[index]['_id'] ?? '';
            final maxLen = 12;
            final display = (fullName.length > maxLen) ? '${fullName.substring(0, maxLen)}...' : fullName;
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 10,
              child: Transform.rotate(
              angle: -pi / 6,
              child: Text(
                display,
                style: GoogleFonts.montserrat(
                fontSize: 11,
                color: darkColor,
                fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              ),
            );
            },
          ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, m) => Text(
            v.toInt().toString(),
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: grayColor,
              fontWeight: FontWeight.w500,
            ),
            ),
          ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(
          color: grayColor.withOpacity(0.15),
          strokeWidth: 1,
          ),
        ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOutCubic,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF21464E))),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 8, color: CustomPallete.darkColor, height: 1.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}