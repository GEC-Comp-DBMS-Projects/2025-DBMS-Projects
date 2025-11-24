import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class CardioWorkoutPage extends StatefulWidget {
  final int totalDays;
  final int currentDay;

  const CardioWorkoutPage({
    super.key,
    required this.totalDays,
    required this.currentDay,
  });

  @override
  State<CardioWorkoutPage> createState() => _CardioWorkoutPageState();
}

class _CardioWorkoutPageState extends State<CardioWorkoutPage> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  bool isCompleted = false;

  // Workout sequence used by the timer UI. Each item: {name, duration, isRest, calPerMin}
  List<Map<String, dynamic>> sequence = [];
  int currentIndex = 0;
  int remainingSeconds = 0;
  Timer? _seqTimer;
  bool playing = false;

  // track pending calories to flush to Firestore
  double _pendingCaloriesToFlush = 0.0;
  DateTime? _lastCaloriesFlush;
  final Duration _caloriesFlushInterval = const Duration(seconds: 15);

  // Helper function to get image path for an exercise
  String _getExerciseImage(String exerciseName) {
    // Map exercise names to their image paths (including common variations)
    final imageMap = {
      // Yoga poses
      'Bridge Pose': 'assets/images/Bridge Pose.jpg',
      'Cat-Cow Stretch': 'assets/images/Cat-Cow Stretch.jpg',
      'Cat Cow': 'assets/images/Cat-Cow Stretch.jpg',
      'Child\'s Pose': 'assets/images/Child\'s Pose.webp',
      'Childs Pose': 'assets/images/Child\'s Pose.webp',
      'Cobra Pose': 'assets/images/Cobra Pose.jpg',
      'Downward Dog': 'assets/images/Downward Dog.jpg',
      'Final Savasana': 'assets/images/Final savasana.png',
      'Final savasana': 'assets/images/Final savasana.png',
      'Savasana': 'assets/images/Final savasana.png',
      'Mountain Pose': 'assets/images/Mountain Pose.jpg',
      'Pigeon Pose': 'assets/images/Pigeon Pose.jpg',
      'Seated Forward Bend': 'assets/images/Seated Forward Bend.jpg',
      'Tree Pose': 'assets/images/Tree Pose.jpg',
      'Triangle Pose': 'assets/images/Triangle Pose.jpg',
      'Warrior I': 'assets/images/Warrior I.jpg',
      'Warrior 1': 'assets/images/Warrior I.jpg',
      'Warrior II': 'assets/images/Warrior II.jpg',
      'Warrior 2': 'assets/images/Warrior II.jpg',
      
      // Cardio exercises
      'Burpees': 'assets/images/Burpees.jpg',
      'burpee': 'assets/images/Burpees.jpg',
      'Burpee': 'assets/images/Burpees.jpg',
      'Butt Kicks': 'assets/images/butt kicks.jpg',
      'Butt kicks': 'assets/images/butt kicks.jpg',
      'butt kick': 'assets/images/butt kicks.jpg',
      'Frog Jumps': 'assets/images/frog jumps.jpg',
      'Frog jumps': 'assets/images/frog jumps.jpg',
      'frog jump': 'assets/images/frog jumps.jpg',
      'High Knees': 'assets/images/High knees.jpg',
      'High knees': 'assets/images/High knees.jpg',
      'high knee': 'assets/images/High knees.jpg',
      'Inchworms': 'assets/images/Inchworms.jpg',
      'inchworm': 'assets/images/Inchworms.jpg',
      'Jump Squats': 'assets/images/Jump Squats.jpg',
      'jump squat': 'assets/images/Jump Squats.jpg',
      'Jumping Jacks': 'assets/images/Jumping Jacks.jpg',
      'jumping jack': 'assets/images/Jumping Jacks.jpg',
      'Mountain Climbers': 'assets/images/Mountain Climbers.jpg',
      'mountain climber': 'assets/images/Mountain Climbers.jpg',
      'Plank Jacks': 'assets/images/Plank Jacks.jpg',
      'plank jack': 'assets/images/Plank Jacks.jpg',
      'Shadow Boxing': 'assets/images/shadow boxing.jpg',
      'Shadow boxing': 'assets/images/shadow boxing.jpg',
      'shadow box': 'assets/images/shadow boxing.jpg',
      'Skater Jumps': 'assets/images/skater jumps.jpg',
      'Skater Jump': 'assets/images/skater jumps.jpg',
      'skater': 'assets/images/skater jumps.jpg',
      'Speed Skaters': 'assets/images/speedskaters.jpg',
      'Speed skaters': 'assets/images/speedskaters.jpg',
      'speed skater': 'assets/images/speedskaters.jpg',
      'Sprint in Place': 'assets/images/sprint in place.jpg',
      'sprint': 'assets/images/sprint in place.jpg',
      'Star Jumps': 'assets/images/star jump.jpg',
      'Star Jump': 'assets/images/star jump.jpg',
      'star': 'assets/images/star jump.jpg',
      'Tuck Jumps': 'assets/images/tuck jumps.jpg',
      'Tuck Jump': 'assets/images/tuck jumps.jpg',
      'tuck': 'assets/images/tuck jumps.jpg',
      
      // Strength exercises
      'Alternating Plyometric Lunges': 'assets/images/Alternating Plyometric Lunges.jpg',
      'alternating lunges': 'assets/images/Alternating Plyometric Lunges.jpg',
      'Bent-over Rows': 'assets/images/Bent-over Rows.jpg',
      'bent over rows': 'assets/images/Bent-over Rows.jpg',
      'Bent Over Rows': 'assets/images/Bent-over Rows.jpg',
      'Bodyweight Squats': 'assets/images/Bodyweight Squats.jpg',
      'bodyweight squat': 'assets/images/Bodyweight Squats.jpg',
      'Chest Press': 'assets/images/Chest Press.jpg',
      'chest press': 'assets/images/Chest Press.jpg',
      'Crunches': 'assets/images/crunches.jpg',
      'crunches': 'assets/images/crunches.jpg',
      'crunch': 'assets/images/crunches.jpg',
      'Deadlifts': 'assets/images/Deadlifts.jpg',
      'deadlift': 'assets/images/Deadlifts.jpg',
      'Dips': 'assets/images/Dips (Chair).jpg',
      'Dips (Chair)': 'assets/images/Dips (Chair).jpg',
      'dip': 'assets/images/Dips (Chair).jpg',
      'Dumbbell Rows': 'assets/images/Dumbbell Rows.jpg',
      'dumbbell rows': 'assets/images/Dumbbell Rows.jpg',
      'Flutter Kicks': 'assets/images/Flutter Kicks.jpg',
      'flutter kicks': 'assets/images/Flutter Kicks.jpg',
      'Glute Bridges': 'assets/images/Glute Bridges.jpg',
      'glute bridge': 'assets/images/Glute Bridges.jpg',
      'Goblet Squats': 'assets/images/Goblet Squats.jpg',
      'goblet squat': 'assets/images/Goblet Squats.jpg',
      'Lunges': 'assets/images/Lunges.jpg',
      'lunge': 'assets/images/Lunges.jpg',
      'Overhead Press': 'assets/images/Overhead Press.jpg',
      'overhead press': 'assets/images/Overhead Press.jpg',
      'Plank': 'assets/images/Plank.jpg',
      'plank': 'assets/images/Plank.jpg',
      'Pull-ups': 'assets/images/Pull-ups.jpg',
      'pull up': 'assets/images/Pull-ups.jpg',
      'Push-ups': 'assets/images/Push-ups.jpg',
      'push up': 'assets/images/Push-ups.jpg',
      'Reverse Lunges': 'assets/images/Reverse Lunges.jpg',
      'reverse lunge': 'assets/images/Reverse Lunges.jpg',
      'Romanian Deadlift': 'assets/images/Romanian Deadlift.jpg',
      'romanian deadlift': 'assets/images/Romanian Deadlift.jpg',
      'Russian Twists': 'assets/images/Russian Twists.jpg',
      'russian twist': 'assets/images/Russian Twists.jpg',
      'Shoulder Taps': 'assets/images/Shoulder Taps.jpg',
      'shoulder taps': 'assets/images/Shoulder Taps.jpg',
      'Side Plank': 'assets/images/Side Plank.jpg',
      'side plank': 'assets/images/Side Plank.jpg',
      'Squats': 'assets/images/Squats.jpg',
      'squat': 'assets/images/Squats.jpg',
      'Wall Sit': 'assets/images/Wall Sit.jpg',
      'wall sit': 'assets/images/Wall Sit.jpg',
      
      // Rest
      'Rest': 'assets/images/fitness_bg.jpg',
    };

    // Try exact match first
    if (imageMap.containsKey(exerciseName)) {
      return imageMap[exerciseName]!;
    }

    // Try case-insensitive fuzzy matching
    final normalizedExercise = exerciseName.toLowerCase().trim();
    for (var entry in imageMap.entries) {
      final normalizedKey = entry.key.toLowerCase();
      if (normalizedExercise.contains(normalizedKey) || normalizedKey.contains(normalizedExercise)) {
        return entry.value;
      }
    }

    // Return a default image if no match found
    print('No image found for exercise: $exerciseName');
    return 'assets/images/fitness_bg.jpg';
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cardio_workouts')
          .doc('day_${widget.currentDay}')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
          isLoading = false;
        });
        _buildSequenceFromExercises();
      } else {
        // If no specific exercises found, generate a sample routine
        setState(() {
          exercises = _getDefaultExercises();
          isLoading = false;
        });
        _buildSequenceFromExercises();
      }
    } catch (e) {
      print('Error loading exercises: $e');
      setState(() {
        exercises = _getDefaultExercises();
        isLoading = false;
      });
      _buildSequenceFromExercises();
    }
  }

  List<Map<String, dynamic>> _getDefaultExercises() {
    return [
      {
        'name': 'High Knees',
        'sets': 3,
        'reps': '45 seconds',
        'restTime': '30 seconds',
      },
      {
        'name': 'Mountain Climbers',
        'sets': 3,
        'reps': '45 seconds',
        'restTime': '30 seconds',
      },
      {
        'name': 'Jumping Jacks',
        'sets': 3,
        'reps': '45 seconds',
        'restTime': '30 seconds',
      },
      {
        'name': 'Burpees',
        'sets': 3,
        'reps': '30 seconds',
        'restTime': '45 seconds',
      },
    ];
  }

  void _buildSequenceFromExercises() {
    // If Firestore exercises include durationSeconds, use them; otherwise generate a sample routine
    if (exercises.isNotEmpty &&
        exercises.first.containsKey('durationSeconds')) {
      sequence = exercises.map((e) {
        return {
          'name': e['name'] ?? 'Exercise',
          'duration': e['durationSeconds'] ?? 60,
          'isRest': e['isRest'] ?? false,
          'calPerMin': e['calPerMin'] ?? 10.0, // higher for cardio
        };
      }).toList();
    } else {
      sequence = _generateSampleRoutine('cardio');
    }

    currentIndex = 0;
    remainingSeconds = sequence.isNotEmpty ? sequence[0]['duration'] as int : 0;
  }

  List<Map<String, dynamic>> _generateSampleRoutine(String category) {
    // cardio-focused exercises with higher intensity
    final exercises = [
      'High Knees',
      'Burpees',
      'Jump Squats',
      'Mountain Climbers',
      'Skaters',
      'Butt Kicks',
      'Plank Jacks',
      'Alternating Lunges (plyo)',
      'Tuck Jumps',
      'Speed Skaters',
    ];
    final durations = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    final rest = 40;

    List<Map<String, dynamic>> seq = [];
    for (var i = 0; i < exercises.length; i++) {
      seq.add({
        'name': exercises[i],
        'duration': durations[i],
        'isRest': false,
        'calPerMin': 10.0, // cardio burns more calories per minute
      });
      if ((i + 1) % 4 == 0 && i != exercises.length - 1) {
        seq.add({
          'name': 'Rest',
          'duration': rest,
          'isRest': true,
          'calPerMin': 0.0,
        });
      }
    }

    // If total less than 20 min, append a finisher
    int total = seq.fold(0, (s, e) => s + (e['duration'] as int));
    if (total < 18 * 60) {
      seq.add({
        'name': 'Finisher Sprint',
        'duration': 60,
        'isRest': false,
        'calPerMin': 12.0, // higher intensity finisher
      });
    }
    return seq;
  }

  void _startSequence() {
    if (sequence.isEmpty) return;
    if (playing) return;
    setState(() => playing = true);

    _seqTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds > 0) {
        // accumulate calories per second for the current step
        try {
          final step = sequence[currentIndex];
          final calPerMin = (step['calPerMin'] as num).toDouble();
          final calThisSecond = calPerMin / 60.0;
          _pendingCaloriesToFlush += calThisSecond;
        } catch (_) {}

        // flush to Firestore occasionally to avoid too many writes
        if (_shouldFlushCalories()) {
          await _flushPendingCalories();
        }

        setState(() => remainingSeconds--);
      } else {
        // step finished
        await _onStepComplete();
      }
    });
  }

  void _pauseSequence() {
    _seqTimer?.cancel();
    _seqTimer = null;
    setState(() => playing = false);
  }

  void _resetSequence() {
    _pauseSequence();
    setState(() {
      currentIndex = 0;
      remainingSeconds = sequence.isNotEmpty
          ? sequence[0]['duration'] as int
          : 0;
    });
  }

  Future<void> _onStepComplete() async {
    // vibrate / sound
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}

    // Ensure any pending calories are flushed
    await _flushPendingCalories(force: true);

    // advance to next step
    if (currentIndex < sequence.length - 1) {
      setState(() {
        currentIndex++;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    } else {
      // finished workout
      _pauseSequence();
      // final flush
      await _flushPendingCalories(force: true);
      await _markDayAsCompleted();
    }
  }

  void _goToNext() {
    if (currentIndex < sequence.length - 1) {
      setState(() {
        currentIndex++;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    }
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    }
  }

  bool _shouldFlushCalories() {
    if (_pendingCaloriesToFlush >= 1.0) return true;
    if (_lastCaloriesFlush == null) return true;
    return DateTime.now().difference(_lastCaloriesFlush!) >=
        _caloriesFlushInterval;
  }

  Future<void> _flushPendingCalories({bool force = false}) async {
    if (!force && _pendingCaloriesToFlush <= 0) return;
    final toFlush = _pendingCaloriesToFlush;
    if (toFlush <= 0) return;

    await _addCalories(toFlush);
    _pendingCaloriesToFlush = 0.0;
    _lastCaloriesFlush = DateTime.now();
  }

  Future<void> _addCalories(double calories) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save calories')),
        );
      }
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection('cardio_workout')
          .doc('current_progress');

      final snapshot = await docRef.get();
      final current = (snapshot.exists && snapshot.data() != null)
          ? (snapshot.data()!['calories_burned'] as num? ?? 0)
          : 0;

      await docRef.set({
        'calories_burned': current + calories,
        'last_updated': DateTime.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving calories: $e')));
      }
    }
  }

  Future<void> _markDayAsCompleted() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to mark progress')),
        );
        context.go('/login');
      }
      return;
    }

    try {
      // flush any remaining calories
      await _flushPendingCalories(force: true);

      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection('cardio_workout')
          .doc('current_progress')
          .set({
            'last_completed_day': widget.currentDay,
            'total_days': widget.totalDays,
            'last_updated': DateTime.now(),
          }, SetOptions(merge: true));

      setState(() {
        isCompleted = true;
      });

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Day Completed! 🎉'),
            content: Text(
              'You\'ve completed Day ${widget.currentDay} of ${widget.totalDays}.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Return to days list
        context.go('/cardio-days/${widget.totalDays}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating progress: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Day ${widget.currentDay} of ${widget.totalDays}'),
      ),
      floatingActionButton: !isCompleted
          ? FloatingActionButton.extended(
              onPressed: _markDayAsCompleted,
              icon: const Icon(Icons.check),
              label: const Text('Complete Workout'),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day ${widget.currentDay}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercises.length} Exercises',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer UI
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: sequence.isEmpty
                        ? const Center(
                            child: Text('No workout sequence available'),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Exercise image
                              Container(
                                height: 200,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    _getExerciseImage(sequence[currentIndex]['name']),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.fitness_center, size: 60),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Circular progress
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: sequence[currentIndex].isNotEmpty
                                          ? 1 -
                                                (remainingSeconds /
                                                    (sequence[currentIndex]['duration']
                                                        as int))
                                          : 0,
                                      strokeWidth: 10,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sequence[currentIndex]['name'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Next Up'),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentIndex < sequence.length - 1
                                            ? sequence[currentIndex + 1]['name']
                                            : '—',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _goToPrevious();
                                    },
                                    icon: const Icon(Icons.skip_previous),
                                    iconSize: 36,
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      if (playing) {
                                        _pauseSequence();
                                      } else {
                                        _startSequence();
                                      }
                                    },
                                    child: Icon(
                                      playing ? Icons.pause : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _goToNext();
                                    },
                                    icon: const Icon(Icons.skip_next),
                                    iconSize: 36,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _resetSequence();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reset'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
