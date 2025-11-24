import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/auth_service.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = AuthService();

  Map<String, dynamic>? _userData;
  List<dynamic> _workoutHistory = [];
  Map<String, int> _weeklyStats = {};
  Map<String, dynamic> _streakInfo = {};
  List<Map<String, dynamic>> _planEntries = [];
  bool _isLoading = true;

  // Stream subscriptions
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  StreamSubscription<QuerySnapshot>? _workoutHistorySubscription;
  StreamSubscription<QuerySnapshot>? _planProgressSubscription;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _workoutHistorySubscription?.cancel();
    _planProgressSubscription?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    final userId = _auth.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // User data stream
    _userDataSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              _userData = snapshot.data();
              _streakInfo = {
                'currentStreak': _userData?['currentStreak'] ?? 0,
                'bestStreak': _userData?['bestStreak'] ?? 0,
                'lastWorkoutDate': _userData?['lastWorkoutDate'],
              };
            });
          }
        });

    // Workout history stream
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    _workoutHistorySubscription = _firestore
        .collection('workout_sessions')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: weekStartDate)
        .snapshots()
        .listen((snapshot) {
          final Map<String, int> stats = {};
          final List<dynamic> history = [];

          // Initialize all days with 0
          for (int i = 1; i <= 7; i++) {
            stats[i.toString()] = 0;
          }

          for (var doc in snapshot.docs) {
            final data = doc.data();
            history.add(data);

            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final weekday = timestamp.weekday;
            stats[weekday.toString()] =
                (stats[weekday.toString()] ?? 0) +
                (data['caloriesBurned'] as num? ?? 0).toInt();
          }

          setState(() {
            _weeklyStats = stats;
            _workoutHistory = history;
          });
        });

    // Plan progress stream
    _planProgressSubscription = _firestore
        .collection('plan_progress')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _planEntries = snapshot.docs.map((doc) => doc.data()).toList();
          });
        });

    setState(() => _isLoading = false);
  }

  List<FlSpot> _getWeeklyCaloriesSpots() {
    const days = 7;
    return List.generate(days, (i) {
      final key = (i + 1).toString();
      final calories = _weeklyStats[key] ?? 0;
      return FlSpot(i.toDouble(), calories.toDouble());
    });
  }

  List<BarChartGroupData> _getWeeklyWorkoutBars() {
    return List.generate(7, (i) {
      final key = (i + 1).toString();
      final calories = _weeklyStats[key] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: calories.toDouble(),
            width: 16,
            color: const Color(0xFF007BFF),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Progress Tracker'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartSection(
                    title: 'Weekly Calories (line)',
                    icon: Icons.local_fire_department,
                    child: SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            horizontalInterval: 100,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 100,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getWeeklyCaloriesSpots(),
                              isCurved: true,
                              color: const Color(0xFFFF5722),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFFFF5722),
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFFFF5722).withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipBorder: const BorderSide(
                                color: Color(0xFFFF5722),
                                width: 1,
                              ),
                              tooltipMargin: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((
                                  LineBarSpot touchedSpot,
                                ) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ];
                                  final index = touchedSpot.x.toInt();
                                  final day = index >= 0 && index < days.length
                                      ? days[index]
                                      : '';
                                  return LineTooltipItem(
                                    '$day\n${touchedSpot.y.toInt()} cal',
                                    const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildChartSection(
                    title: 'Calories Burned (bar)',
                    icon: Icons.bar_chart,
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _weeklyStats.values.isEmpty
                              ? 100
                              : (_weeklyStats.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) *
                                        1.2)
                                    .toDouble(),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            horizontalInterval: 100,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 100,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _getWeeklyWorkoutBars(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipBorder: const BorderSide(
                                color: Color(0xFF007BFF),
                                width: 1,
                              ),
                              tooltipMargin: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    const days = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    final day =
                                        groupIndex >= 0 &&
                                            groupIndex < days.length
                                        ? days[groupIndex]
                                        : '';
                                    return BarTooltipItem(
                                      '$day\n${rod.toY.toInt()} cal',
                                      const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Plan Progress section (separate)
                  _buildChartSection(
                    title: 'Plan Progress',
                    icon: Icons.calendar_today,
                    child: SizedBox(
                      height: _planEntries.isEmpty
                          ? 80
                          : (_planEntries.length.clamp(0, 6) * 80).toDouble(),
                      child: _planEntries.isEmpty
                          ? const Center(child: Text('No plan progress yet'))
                          : ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _planEntries.length.clamp(0, 6),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final entry = _planEntries[index];
                                final date =
                                    entry['date'] ?? entry['timestamp'] ?? '';
                                final dayIndex = entry['dayIndex'] ?? 0;
                                final calories = entry['caloriesBurned'] ?? 0;
                                final exerciseDetails =
                                    (entry['exerciseDetails'] as List?) ?? [];
                                return ExpansionTile(
                                  title: Text(
                                    'Day $dayIndex • ${date.toString().split('T').first}',
                                  ),
                                  subtitle: Text('$calories cal'),
                                  children: exerciseDetails.map<Widget>((ex) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(ex['name'] ?? ''),
                                      trailing: Text(
                                        '${ex['caloriesBurned'] ?? 0} cal',
                                      ),
                                      subtitle: Text(
                                        'Completed at: ${ex['completedAt'] ?? ''}',
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSummaryStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007BFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Workouts',
                  '${_userData?['workoutsCompleted'] ?? 0}',
                  Icons.fitness_center,
                  const Color(0xFF007BFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Calories',
                  '${_userData?['caloriesBurned'] ?? 0}',
                  Icons.local_fire_department,
                  const Color(0xFFFF5722),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Workouts',
                  '${_workoutHistory.length}',
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Streak',
                  '${_streakInfo['currentStreak'] ?? 0} days',
                  Icons.whatshot,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
