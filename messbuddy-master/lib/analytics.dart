import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State
  Map<int, Map<String, int>> _weeklyAnalyticsData = {};
  int _totalWeeklyMeals = 0;
  bool _isLoadingAnalytics = true;
  double _maxY = 10;

  // Theme Colors
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _accentColor = const Color(0xFF04E9CC);
  final Color _secondaryAccent = const Color(0xFF7F5AF7);
  final Color _vegColor = Colors.green.shade400;
  final Color _nonVegColor = Colors.orange.shade400;
  final String _chartEmoji = "📊";

  @override
  void initState() {
    super.initState();
    _fetchWeeklyAnalytics();
  }

  Future<void> _fetchWeeklyAnalytics() async {
    setState(() => _isLoadingAnalytics = true);

    Map<int, Map<String, int>> weeklyData = {};
    double maxCount = 0;
    double totalWeekCount = 0;

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    List<Future<Map<String, dynamic>>> dailyFetchFutures = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startOfWeek.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDay);
      dailyFetchFutures.add(
        _getPreferencesForDay(formattedDate)
            .then((prefs) => {'day': currentDay.weekday, 'prefs': prefs}),
      );
    }

    try {
      final dailyResults = await Future.wait(dailyFetchFutures);

      for (var result in dailyResults) {
        int dayOfWeek = result['day'];
        Map<String, int> prefs = result['prefs'];
        weeklyData[dayOfWeek] = prefs;

        double totalDayCount =
            (prefs['veg']?.toDouble() ?? 0.0) + (prefs['nonVeg']?.toDouble() ?? 0.0);
        if (totalDayCount > maxCount) {
          maxCount = totalDayCount;
        }
        totalWeekCount += totalDayCount;
      }

      if (mounted) {
        setState(() {
          _weeklyAnalyticsData = weeklyData;
          _totalWeeklyMeals = totalWeekCount.toInt();
          _maxY = (maxCount == 0) ? 10 : (maxCount * 1.2).ceilToDouble();
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching weekly analytics: $e");
      if (mounted) {
        for (int i = 1; i <= 7; i++) {
          weeklyData[i] = {'veg': 0, 'nonVeg': 0};
        }
        setState(() {
          _weeklyAnalyticsData = weeklyData;
          _totalWeeklyMeals = 0;
          _maxY = 10;
          _isLoadingAnalytics = false;
        });
      }
    }
  }

  Future<Map<String, int>> _getPreferencesForDay(String formattedDate) async {
    int vegCount = 0;
    int nonVegCount = 0;
    try {
      final mealsSnapshot = await _firestore
          .collection('attendance')
          .doc(formattedDate)
          .collection('meals')
          .get();

      for (var mealDoc in mealsSnapshot.docs) {
        final data = mealDoc.data();
        final List<dynamic> attendees = data['attendees'] ?? [];
        for (var attendee in attendees) {
          if (attendee is Map<String, dynamic>) {
            final preference = attendee['preference'] as String?;
            if (preference == 'veg') {
              vegCount++;
            } else if (preference == 'non-veg') {
              nonVegCount++;
            }
          }
        }
      }
      return {'veg': vegCount, 'nonVeg': nonVegCount};
    } catch (e) {
      debugPrint("Error fetching preferences for $formattedDate: $e");
      return {'veg': 0, 'nonVeg': 0};
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'weekly analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWeeklyAnalytics,
        backgroundColor: _cardBackgroundColor,
        color: _accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _isLoadingAnalytics
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100.0),
                    child: CircularProgressIndicator(color: _accentColor),
                  ),
                )
              : _buildWeeklyAnalyticsCard(),
        ),
      ),
    );
  }

  Widget _buildWeeklyAnalyticsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: _secondaryAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'weekly booking report',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(_chartEmoji, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'count of veg vs. non-veg meals booked this week.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textSecondaryColor,
            ),
          ),
          const SizedBox(height: 25),
          _buildTotalMealsSummary(),
          const SizedBox(height: 25),
          _buildChartLegend(),
          const SizedBox(height: 25),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                barTouchData: _buildBarTouchData(),
                titlesData: _buildChartTitles(),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                    left: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.07),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                alignment: BarChartAlignment.spaceEvenly,
                groupsSpace: 25,
                barGroups: _buildBarGroups(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 500),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'daily totals',
            style: GoogleFonts.poppins(
              color: _textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          _buildDailyBreakdownList(),
        ],
      ),
    );
  }

  Widget _buildTotalMealsSummary() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBackgroundAltColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              _totalWeeklyMeals.toString(),
              style: GoogleFonts.poppins(
                color: _accentColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'total meals this week',
              style: GoogleFonts.poppins(
                color: _textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdownList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBackgroundAltColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(7, (index) {
          int day = index + 1;
          final dayData = _weeklyAnalyticsData[day] ?? {'veg': 0, 'nonVeg': 0};
          final total = dayData['veg']! + dayData['nonVeg']!;
          final dayName = _getDayName(day);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              border: index == 6
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: GoogleFonts.poppins(
                    color: _textSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$total meals',
                  style: GoogleFonts.poppins(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _vegColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Veg',
              style: GoogleFonts.poppins(
                  color: _textSecondaryColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _nonVegColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Non-Veg',
              style: GoogleFonts.poppins(
                  color: _textSecondaryColor, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];
    // 🔽 --- DEFINE EMPTY BAR COLOR --- 🔽
    final Color emptyBarColor = Colors.grey.withOpacity(0.1); 

    for (int day = 1; day <= 7; day++) {
      final dayData = _weeklyAnalyticsData[day] ?? {'veg': 0, 'nonVeg': 0};
      final vegCount = dayData['veg']!.toDouble();
      final nonVegCount = dayData['nonVeg']!.toDouble();
      final total = vegCount + nonVegCount;

      final vegPercentage = total > 0 ? (vegCount / total) * 100 : 0.0;
      final nonVegPercentage = total > 0 ? (nonVegCount / total) * 100 : 0.0;

      barGroups.add(
        BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: 100,
              width: 22,
              borderRadius: BorderRadius.circular(6),
              // 🔽 --- THIS IS THE FIX --- 🔽
              // Conditionally set the stack items
              rodStackItems: total == 0
                  ? [
                      // If no meals, draw one full grey bar
                      BarChartRodStackItem(0, 100, emptyBarColor),
                    ]
                  : [
                      // Otherwise, draw the stacked veg/non-veg
                      BarChartRodStackItem(0, nonVegPercentage, _nonVegColor),
                      BarChartRodStackItem(nonVegPercentage, 100, _vegColor),
                    ],
              // 🔼 --- END OF FIX --- 🔼
              
              // We can disable backDrawRodData now, as our stack handles the empty case
              backDrawRodData: BackgroundBarChartRodData(
                show: false,
              ),
            ),
          ],
          // This line is removed to only show tooltip on hover
          // showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitlesWidget: (value, meta) {
            const style = TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            );
            String text;
            switch (value.toInt()) {
              case 1:
                text = 'MON';
                break;
              case 2:
                text = 'TUE';
                break;
              case 3:
                text = 'WED';
                break;
              case 4:
                text = 'THU';
                break;
              case 5:
                text = 'FRI';
                break;
              case 6:
                text = 'SAT';
                break;
              case 7:
                text = 'SUN';
                break;
              default:
                text = '';
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(text, style: style),
              // axisSide: meta.axisSide, // This line was removed (THE FIX)
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 20,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return SideTitleWidget(
              meta: meta,
              child: Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => _cardBackgroundAltColor.withOpacity(0.9),
        // 'tooltipRoundedRadius: 8' was removed (THE FIX)
        tooltipMargin: 8,
        tooltipPadding: const EdgeInsets.all(12),
        tooltipBorder: BorderSide(
          color: _accentColor.withOpacity(0.2),
          width: 1,
        ),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final dayData = _weeklyAnalyticsData[group.x] ?? {'veg': 0, 'nonVeg': 0};
          final vegCount = dayData['veg']!;
          final nonVegCount = dayData['nonVeg']!;
          final total = vegCount + nonVegCount;

          final vegPercentage = total > 0 ? (vegCount / total * 100).toStringAsFixed(1) : '0';
          final nonVegPercentage = total > 0 ? (nonVegCount / total * 100).toStringAsFixed(1) : '0';

          String dayText = _getDayName(group.x.toInt());

          // 🔽 --- HIDE TOOLTIP IF NO MEALS --- 🔽
          if (total == 0) {
            return null;
          }
          // 🔼 --- END OF FIX --- 🔼

          return BarTooltipItem(
            '$dayText\n',
            GoogleFonts.poppins(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Total: $total meals\n',
                style: GoogleFonts.poppins(
                  color: _textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Veg: $vegCount ($vegPercentage%)\n',
                style: GoogleFonts.poppins(
                  color: _vegColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Non-Veg: $nonVegCount ($nonVegPercentage%)',
                style: GoogleFonts.poppins(
                  color: _nonVegColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}