import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/workout_service.dart';
import 'package:flutter/services.dart';

class HomeWorkoutPage extends StatefulWidget {
  final int totalDays;
  final int currentDay;

  const HomeWorkoutPage({
    super.key,
    required this.totalDays,
    required this.currentDay,
  });

  @override
  State<HomeWorkoutPage> createState() => _HomeWorkoutPageState();
}

class _HomeWorkoutPageState extends State<HomeWorkoutPage> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  bool isCompleted = false;
  
  List<Map<String, dynamic>> sequence = [];
  int currentIndex = 0;
  int remainingSeconds = 0;
  Timer? _seqTimer;
  bool playing = false;
  int _totalPlannedSeconds = 0;

  final WorkoutService _workoutService = WorkoutService();

  double _pendingCaloriesToFlush = 0.0;
  DateTime? _lastCaloriesFlush;
  final Duration _caloriesFlushInterval = const Duration(seconds: 15);

  Future<void> _markDayAsCompleted() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to mark progress')),
        );
      }
      context.go('/login');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection('home_workouts')
          .doc('current_progress')
          .set({
        'last_completed_day': widget.currentDay,
        'total_days': widget.totalDays,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mirror to legacy path for backward compatibility
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection('home_workout')
          .doc('current_progress')
          .set({
        'last_completed_day': widget.currentDay,
        'total_days': widget.totalDays,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        isCompleted = true;
      });

      // Record structured entries similar to auto flow
      await _workoutService.recordWorkout(
        workoutId: 'home_workouts_day_${widget.currentDay}',
        workoutName: 'Home Workout Day ${widget.currentDay}',
        durationSeconds: _totalPlannedSeconds,
      );
      await _workoutService.recordPlanDay(
        planType: 'home_workouts',
        dayIndex: widget.currentDay,
        dayName: 'Day ${widget.currentDay}',
        durationSeconds: _totalPlannedSeconds,
        exerciseDetails: sequence
            .where((e) => (e['isRest'] as bool?) != true)
            .map((e) => {
                  'name': e['name'],
                  'duration': e['duration'],
                })
            .toList(),
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Day Completed! 🎉'),
          content: Text(
            'You\'ve completed Day ${widget.currentDay} of ${widget.totalDays}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (mounted) {
        context.go('/home-days/${widget.totalDays}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating progress: $e')),
        );
      }
    }
  }

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
      'Plank Hold': 'assets/images/Plank.jpg',
      'plank': 'assets/images/Plank.jpg',
      'Pull-ups': 'assets/images/Pull-ups.jpg',
      'pull up': 'assets/images/Pull-ups.jpg',
      'Push-ups': 'assets/images/Push-ups.jpg',
      'push up': 'assets/images/Push-ups.jpg',
      'Chair Dips': 'assets/images/Dips (Chair).jpg',
      'Dips (chair)': 'assets/images/Dips (Chair).jpg',
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
    setState(() => isLoading = true);

    try {
      // Prefer new structure: home_workouts/day_{N}; fallback to legacy: workouts/home_workout/days/dayN
      final newDocRef = FirebaseFirestore.instance
          .collection('home_workouts')
          .doc('day_${widget.currentDay}');
      final legacyDocRef = FirebaseFirestore.instance
          .collection('workouts')
          .doc('home_workout')
          .collection('days')
          .doc('day${widget.currentDay}');

      DocumentSnapshot<Map<String, dynamic>> doc = await newDocRef.get();
      if (!doc.exists) {
        doc = await legacyDocRef.get();
      }
      
      List<Map<String, dynamic>> defaultExercises() {
        return [
          {'name': 'Jumping Jacks', 'duration': 40},
          {'name': 'Bodyweight Squats', 'duration': 45},
          {'name': 'Push-ups', 'duration': 35},
          {'name': 'Glute Bridges', 'duration': 40},
          {'name': 'High Knees', 'duration': 40},
          {'name': 'Plank', 'duration': 40},
        ];
      }

      if (!doc.exists) {
        // No Firestore data → fall back to a simple default routine
        exercises = defaultExercises();
      } else {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> rawExercises = data['exercises'] ?? [];
        exercises = rawExercises.map((e) => Map<String, dynamic>.from(e)).toList();
        if (exercises.isEmpty) {
          exercises = defaultExercises();
        }
      }

      // Check completion status (new collection first, then legacy)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final progressNewRef = FirebaseFirestore.instance
            .collection('user_progress')
            .doc(user.uid)
            .collection('home_workouts')
            .doc('current_progress');
        final progressOldRef = FirebaseFirestore.instance
            .collection('user_progress')
            .doc(user.uid)
            .collection('home_workout')
            .doc('current_progress');

        final progressNew = await progressNewRef.get();
        final progressOld = !progressNew.exists ? await progressOldRef.get() : null;
        final pData = progressNew.exists
            ? progressNew.data() as Map<String, dynamic>
            : progressOld?.data();
        if (pData != null) {
          isCompleted = (pData['last_completed_day'] ?? 0) >= widget.currentDay;
        }
      }

      // Build timer sequence
      sequence = [];
      for (final exercise in exercises) {
        final duration = (exercise['duration'] ?? 30) as int;
        sequence.add({
          'name': exercise['name'],
          'duration': duration,
          'isRest': false,
          'calPerMin': 7.0 // Average calories burned per minute for home exercises
        });

        // Add rest period after each exercise except the last one
        if (exercise != exercises.last) {
          sequence.add({
            'name': 'Rest',
            'duration': 30, // 30 seconds rest between exercises
            'isRest': true,
            'calPerMin': 1.0 // Minimal calories during rest
          });
        }
      }
      // Precompute total planned seconds for logging/progress
      _totalPlannedSeconds = sequence.fold<int>(0, (sum, e) => sum + (e['duration'] as int));

    } catch (e) {
      print('Error loading exercises: $e');
      // As a safety, ensure we still have a routine
      if (exercises.isEmpty) {
        exercises = [
          {'name': 'Jumping Jacks', 'duration': 40},
          {'name': 'Bodyweight Squats', 'duration': 45},
          {'name': 'Push-ups', 'duration': 35},
          {'name': 'Glute Bridges', 'duration': 40},
          {'name': 'High Knees', 'duration': 40},
          {'name': 'Plank', 'duration': 40},
        ];
        sequence = [];
        for (final exercise in exercises) {
          final duration = (exercise['duration'] ?? 30) as int;
          sequence.add({
            'name': exercise['name'],
            'duration': duration,
            'isRest': false,
            'calPerMin': 7.0,
          });
          if (exercise != exercises.last) {
            sequence.add({'name': 'Rest', 'duration': 30, 'isRest': true, 'calPerMin': 1.0});
          }
        }
        _totalPlannedSeconds = sequence.fold<int>(0, (sum, e) => sum + (e['duration'] as int));
      }
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exercises: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _seqTimer?.cancel();
    super.dispose();
  }

  Future<void> _flushPendingCalories({bool force = false}) async {
    if (!force && _pendingCaloriesToFlush <= 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final progressNewRef = FirebaseFirestore.instance
          .collection('user_progress')
          .doc(user.uid)
          .collection('home_workouts')
          .doc('current_progress');
      final progressOldRef = FirebaseFirestore.instance
          .collection('user_progress')
          .doc(user.uid)
          .collection('home_workout')
          .doc('current_progress');

      // Update new path
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(progressNewRef);
        final currentCalories = (doc.data()?['calories_burned'] as num?)?.toDouble() ?? 0.0;
        transaction.set(progressNewRef, {
          'calories_burned': currentCalories + _pendingCaloriesToFlush,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      // Also mirror to legacy path for backward compatibility
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(progressOldRef);
        final currentCalories = (doc.data()?['calories_burned'] as num?)?.toDouble() ?? 0.0;
        transaction.set(progressOldRef, {
          'calories_burned': currentCalories + _pendingCaloriesToFlush,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      _pendingCaloriesToFlush = 0;
      _lastCaloriesFlush = DateTime.now();

    } catch (e) {
      print('Error flushing calories: $e');
    }
  }

  void _updateCalories(double additionalCalories) {
    _pendingCaloriesToFlush += additionalCalories;
    
    final now = DateTime.now();
    if (_lastCaloriesFlush == null || 
        now.difference(_lastCaloriesFlush!) >= _caloriesFlushInterval) {
      _flushPendingCalories();
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home Workout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home Workout')),
        body: const Center(
          child: Text('No exercises found for this day'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home-days/${widget.totalDays}'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isCompleted) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Complete all exercises to finish the day\'s workout'),
                  trailing: Text('${exercises.length} exercises'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (playing) ...[
              // Timer display with large centered exercise image
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Large Exercise image - centered and prominent (no cropping)
                      Container(
                        height: 400,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.purple.shade50,
                                    ],
                                  ),
                                ),
                              ),
                              // Exercise image - using contain to show full image
                              Center(
                                child: Image.asset(
                                  _getExerciseImage(sequence[currentIndex]['name']),
                                  fit: BoxFit.contain,
                                  height: 380,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Image loading error for: ${sequence[currentIndex]['name']}');
                                    print('Attempted path: ${_getExerciseImage(sequence[currentIndex]['name'])}');
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Colors.blue[400]!, Colors.purple[400]!],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.fitness_center, size: 80, color: Colors.white),
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              sequence[currentIndex]['name'],
                                              style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Exercise name with badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          sequence[currentIndex]['name'].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Timer display with progress indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: (sequence[currentIndex]['duration'] - remainingSeconds) / sequence[currentIndex]['duration'],
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Exercise ${currentIndex + 1}/${sequence.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Control buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (currentIndex > 0)
                              _buildControlButton(
                                icon: Icons.skip_previous,
                                label: 'Previous',
                                onPressed: () {
                                  setState(() {
                                    currentIndex--;
                                    remainingSeconds = sequence[currentIndex]['duration'];
                                  });
                                },
                                color: Colors.grey[700]!,
                              ),
                            _buildControlButton(
                              icon: Icons.stop,
                              label: 'Stop',
                              onPressed: () {
                                _seqTimer?.cancel();
                                setState(() {
                                  playing = false;
                                });
                              },
                              color: Colors.red[600]!,
                            ),
                            if (currentIndex < sequence.length - 1)
                              _buildControlButton(
                                icon: Icons.skip_next,
                                label: 'Next',
                                onPressed: () {
                                  setState(() {
                                    currentIndex++;
                                    remainingSeconds = sequence[currentIndex]['duration'];
                                  });
                                },
                                color: Colors.grey[700]!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Exercise list
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(exercise['name']),
                        subtitle: Text('${exercise['duration']} seconds'),
                        trailing: exercise['completed'] == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.circle_outlined),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (!isCompleted)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentIndex = 0;
                      remainingSeconds = sequence.isNotEmpty ? sequence[0]['duration'] : 0;
                      playing = true;
                    });
                    
                    _seqTimer?.cancel();
                    _seqTimer = Timer.periodic(
                      const Duration(seconds: 1),
                      (timer) {
                        if (remainingSeconds > 0) {
                          setState(() {
                            remainingSeconds--;
                            
                            // Calculate calories burned in this second
                            final calPerMin = sequence[currentIndex]['calPerMin'];
                            _updateCalories(calPerMin / 60);
                          });
                        } else {
                          // Current exercise/rest completed
                          if (currentIndex < sequence.length - 1) {
                            // Move to next exercise
                            setState(() {
                              currentIndex++;
                              remainingSeconds = sequence[currentIndex]['duration'];
                            });
                          } else {
                            // Workout completed!
                            timer.cancel();
                            setState(() {
                              playing = false;
                              isCompleted = true;
                            });
                            
                            // Update progress in Firestore
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                            // Write to new progress path
                            FirebaseFirestore.instance
                                .collection('user_progress')
                                .doc(user.uid)
                                .collection('home_workouts')
                                .doc('current_progress')
                                .set({
                              'last_completed_day': widget.currentDay,
                              'total_days': widget.totalDays,
                              'last_updated': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));
                            // Mirror to legacy progress path
                            FirebaseFirestore.instance
                                .collection('user_progress')
                                .doc(user.uid)
                                .collection('home_workout')
                                .doc('current_progress')
                                .set({
                              'last_completed_day': widget.currentDay,
                              'total_days': widget.totalDays,
                              'last_updated': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));
                            }

                            // Final calories flush (force)
                            _flushPendingCalories(force: true);

                            // Record structured session and plan progress like other modes
                            _workoutService.recordWorkout(
                              workoutId: 'home_workouts_day_${widget.currentDay}',
                              workoutName: 'Home Workout Day ${widget.currentDay}',
                              durationSeconds: _totalPlannedSeconds,
                            );
                            _workoutService.recordPlanDay(
                              planType: 'home_workouts',
                              dayIndex: widget.currentDay,
                              dayName: 'Day ${widget.currentDay}',
                              durationSeconds: _totalPlannedSeconds,
                              exerciseDetails: sequence
                                  .where((e) => (e['isRest'] as bool?) != true)
                                  .map((e) => {
                                        'name': e['name'],
                                        'duration': e['duration'],
                                      })
                                  .toList(),
                            );

                            // Show completion dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Workout Complete! 🎉'),
                                content: const Text(
                                  'Great job! You\'ve completed today\'s workout.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.go('/home-days/${widget.totalDays}');
                                    },
                                    child: const Text('Back to Days'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Workout'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
