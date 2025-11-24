import 'dart:async';
import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../services/plan_generator.dart';

class PlanPage extends StatefulWidget {
  final String
  planType; // 'home_workouts' | 'strength_training' | 'cardio_workouts'

  const PlanPage({super.key, required this.planType});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  int _selectedLength = 7;
  List<Map<String, dynamic>> _planDays = [];
  Map<String, dynamic> _progress = {};
  final WorkoutService _service = WorkoutService();

  @override
  void initState() {
    super.initState();
    _loadProgressAndDefault();
  }

  Future<void> _loadProgressAndDefault() async {
    final prog = await _service.getUserPlanProgress(widget.planType);
    setState(() {
      _progress = prog;
    });
    _generatePlan(_selectedLength);
  }

  void _generatePlan(int days) {
    setState(() {
      _selectedLength = days;
      _planDays = generatePlan(widget.planType, days);
    });
  }

  int get _completedDays {
    try {
      return _progress['currentDay'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _choosePlanLength(int days) async {
    await _service.setUserPlanChoice(widget.planType, days);
    _generatePlan(days);
  }

  Future<void> _startDay(Map<String, dynamic> day) async {
    final exercises = List<Map<String, dynamic>>.from(day['exercises']);
    final rounds = day['rounds'] as int;

    int currentIndex = 0;
    int currentRound = 1;
    bool inRest = false;
    int countdown = 0;
    Timer? timer;

    // collect per-exercise analytics during the run
    final List<Map<String, dynamic>> exerciseLog = [];

    void startRest(
      int seconds,
      void Function() onDone,
      void Function(void Function()) setLocal,
    ) {
      countdown = seconds;
      inRest = true;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (countdown <= 1) {
          t.cancel();
          inRest = false;
          onDone();
        }
        setLocal(() {
          countdown = (countdown - 1).clamp(0, 999);
        });
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            final current = exercises[currentIndex];
            return AlertDialog(
              title: Text('${day['title']} • Round $currentRound/$rounds'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          current['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${current['duration']} s',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (inRest) ...[
                    Row(
                      children: [
                        const Icon(Icons.hourglass_bottom),
                        const SizedBox(width: 8),
                        const Text('Rest'),
                        const SizedBox(width: 8),
                        Text('$countdown s'),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      'Perform the exercise as prescribed, then press Next.',
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('End'),
                ),
                TextButton(
                  onPressed: currentIndex > 0 && !inRest
                      ? () {
                          setLocal(() {
                            currentIndex -= 1;
                          });
                        }
                      : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (inRest) return;
                    final isLastExercise = currentIndex == exercises.length - 1;
                    // capture the exercise that the user just completed
                    final completedExercise = Map<String, dynamic>.from(
                      current,
                    );
                    startRest(isLastExercise ? 60 : 30, () {
                      // log completion for this exercise
                      final completedAt = DateTime.now();
                      exerciseLog.add({
                        'name': completedExercise['name'],
                        'durationSeconds': completedExercise['duration'],
                        'isRest': completedExercise['isRest'] ?? false,
                        'completedAt': completedAt.toIso8601String(),
                        'caloriesBurned': _service.calculateCaloriesForDuration(
                          widget.planType,
                          completedExercise['duration'] as int,
                        ),
                      });

                      if (isLastExercise) {
                        if (currentRound < rounds) {
                          currentRound += 1;
                          currentIndex = 0;
                        } else {
                          timer?.cancel();
                          Navigator.pop(context);
                          // completed full day -> record with exercise details
                          _recordDayCompletion(day, exerciseLog);
                          return;
                        }
                      } else {
                        currentIndex += 1;
                      }
                      setLocal(() {});
                    }, setLocal);
                  },
                  child: const Text('Next'),
                ),
              ],
            );
          },
        );
      },
    );

    timer?.cancel();
  }

  Future<void> _recordDayCompletion(
    Map<String, dynamic> day, [
    List<Map<String, dynamic>>? exerciseDetails,
  ]) async {
    // estimate total duration seconds
    int total = 0;
    for (var ex in day['exercises']) {
      total += (ex['duration'] as int);
    }
    total = total * (day['rounds'] as int);

    final err = await _service.recordPlanDay(
      planType: widget.planType,
      dayIndex: day['index'] as int,
      dayName: day['title'] as String,
      durationSeconds: total,
      exerciseDetails: exerciseDetails,
    );

    if (err == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Day saved ✅')));
      }
      // refresh progress
      final prog = await _service.getUserPlanProgress(widget.planType);
      setState(() {
        _progress = prog;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved failed: $err')));
      }
    }
  }

  bool _isDayCompleted(int index) {
    try {
      final currentDay = _progress['currentDay'] as int? ?? 0;
      return index <= currentDay;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planType.replaceAll('_', ' ').toUpperCase()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Choose plan length:'),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('7-day'),
                  selected: _selectedLength == 7,
                  onSelected: (s) async {
                    if (s) await _choosePlanLength(7);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('30-day'),
                  selected: _selectedLength == 30,
                  onSelected: (s) async {
                    if (s) await _choosePlanLength(30);
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    // refresh
                    final prog = await _service.getUserPlanProgress(
                      widget.planType,
                    );
                    setState(() {
                      _progress = prog;
                    });
                  },
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: ${_completedDays}/${_selectedLength} days',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _selectedLength > 0
                          ? (_completedDays / _selectedLength)
                          : 0,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _completedDays >= _selectedLength
                              ? null
                              : () {
                                  final nextIdx =
                                      _completedDays; // 0-based in list (day index is 1-based)
                                  if (nextIdx < _planDays.length) {
                                    _startDay(_planDays[nextIdx]);
                                  }
                                },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Resume Next Day'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () async {
                            final prog = await _service.getUserPlanProgress(
                              widget.planType,
                            );
                            setState(() {
                              _progress = prog;
                            });
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _planDays.length,
                itemBuilder: (context, index) {
                  final day = _planDays[index];
                  final completed = _isDayCompleted(day['index'] as int);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: completed
                            ? Colors.green
                            : Colors.blueGrey,
                        child: completed
                            ? const Icon(Icons.check, color: Colors.white)
                            : Text('${day['index']}'),
                      ),
                      title: Text(day['title']),
                      subtitle: Text(
                        '${day['exercises'].length} exercises • ${day['rounds']} rounds',
                      ),
                      trailing: ElevatedButton(
                        onPressed: completed ? null : () => _startDay(day),
                        child: Text(completed ? 'Done' : 'Start'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
