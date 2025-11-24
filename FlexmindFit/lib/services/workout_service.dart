import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';
import 'auth_service.dart';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  // Calculate calories burned based on workout type
  int _calculateCaloriesBurned(String workoutId, int durationMinutes) {
    // Approximate calories per minute for different workout types
    final Map<String, int> caloriesPerMinute = {
      'strength_training': 8,
      'cardio_workouts': 10,
      'home_workouts': 7,
      'yoga_exercises': 3,
    };

    final baseCalories = caloriesPerMinute[workoutId] ?? 8;
    return baseCalories * durationMinutes;
  }

  // Public helper to calculate calories for a duration in seconds
  int calculateCaloriesForDuration(String workoutId, int durationSeconds) {
    final minutes = (durationSeconds / 60).ceil();
    return _calculateCaloriesBurned(workoutId, minutes);
  }

  // Generic Firestore write helper with retries
  Future<T> _writeWithRetry<T>(
    Future<T> Function() fn, {
    int retries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    var delay = initialDelay;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= retries) rethrow;
        print(
          'Write failed (attempt $attempt), retrying in ${delay.inSeconds}s... Error: $e',
        );
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  // Record a completed workout
  Future<String?> recordWorkout({
    required String workoutId,
    required String workoutName,
    required int durationSeconds,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) return 'Not signed in';

    try {
      final durationMinutes = (durationSeconds / 60).ceil();
      final caloriesBurned = _calculateCaloriesBurned(
        workoutId,
        durationMinutes,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        workoutName: workoutName,
        workoutId: workoutId,
        duration: durationSeconds,
        caloriesBurned: caloriesBurned,
        timestamp: now,
        date: today,
      );

      // Save workout session
      await _writeWithRetry(() async {
        await _firestore
            .collection('workout_sessions')
            .doc(session.id)
            .set(session.toMap());
        return null;
      });

      // Update user's total stats
      await _updateUserStats(1, caloriesBurned);

      // Update streak
      await _updateStreak();

      print('✓ Workout recorded: $workoutName, $caloriesBurned calories');
      return null;
    } catch (e) {
      print('✗ Error recording workout: $e');
      return 'Error recording workout: $e';
    }
  }

  // Update user's total workout stats
  Future<void> _updateUserStats(int workoutCount, int calories) async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final currentData = userDoc.data() as Map<String, dynamic>;
        final currentWorkouts = currentData['workoutsCompleted'] ?? 0;
        final currentCalories = currentData['caloriesBurned'] ?? 0;

        await _writeWithRetry(() async {
          await _firestore.collection('users').doc(userId).update({
            'workoutsCompleted': currentWorkouts + workoutCount,
            'caloriesBurned': currentCalories + calories,
            'lastWorkoutDate': DateTime.now().toIso8601String(),
          });
          return null;
        });
      }
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Update user's workout streak
  Future<void> _updateStreak() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final currentData = userDoc.data() as Map<String, dynamic>;
        final currentStreak = currentData['currentStreak'] ?? 0;
        final lastWorkoutDate = currentData['lastWorkoutDate'];

        int newStreak = 1;

        if (lastWorkoutDate != null) {
          final lastDate = DateTime.parse(lastWorkoutDate);
          final today = DateTime.now();
          final yesterday = today.subtract(const Duration(days: 1));

          // Check if last workout was yesterday (continuous streak)
          if (lastDate.year == yesterday.year &&
              lastDate.month == yesterday.month &&
              lastDate.day == yesterday.day) {
            newStreak = currentStreak + 1;
          } else if (lastDate.year == today.year &&
              lastDate.month == today.month &&
              lastDate.day == today.day) {
            // Already worked out today, keep current streak
            return;
          }
        }

        await _writeWithRetry(() async {
          await _firestore.collection('users').doc(userId).update({
            'currentStreak': newStreak,
            'bestStreak': (currentData['bestStreak'] ?? 0) > newStreak
                ? currentData['bestStreak']
                : newStreak,
          });
          return null;
        });
      }
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  // Get workout history
  Future<List<WorkoutSession>> getWorkoutHistory({int days = 7}) async {
    final userId = _auth.currentUserId;
    if (userId == null) return [];

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection('workout_sessions')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: cutoffDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting workout history: $e');
      return [];
    }
  }

  // Get weekly workout stats with real-time updates
  Stream<Map<String, int>> getWeeklyStatsStream() {
    final userId = _auth.currentUserId;
    if (userId == null) return Stream.value({});

    try {
      // Get the start of the current week (Monday)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );

      return _firestore
          .collection('workout_sessions')
          .where('userId', isEqualTo: userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStartDate),
          )
          .snapshots()
          .map((snapshot) {
            final Map<String, int> weeklyStats = {};

            // Initialize all days with 0
            for (int i = 1; i <= 7; i++) {
              weeklyStats[i.toString()] = 0;
            }

            for (var doc in snapshot.docs) {
              final data = doc.data();
              // Handle both Timestamp and String timestamp formats
              final DateTime timestamp;
              if (data['timestamp'] is Timestamp) {
                timestamp = (data['timestamp'] as Timestamp).toDate();
              } else if (data['timestamp'] is String) {
                timestamp = DateTime.parse(data['timestamp'] as String);
              } else {
                continue; // Skip invalid timestamp
              }

              final weekday = timestamp.weekday;
              weeklyStats[weekday.toString()] =
                  (weeklyStats[weekday.toString()] ?? 0) +
                  (data['caloriesBurned'] as num? ?? 0).toInt();
            }

            return weeklyStats;
          });
    } catch (e) {
      print('Error setting up weekly stats stream: $e');
      return Stream.value({});
    }
  }

  // Get user's streak information
  Future<Map<String, dynamic>> getStreakInfo() async {
    final userId = _auth.currentUserId;
    if (userId == null) return {};

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'currentStreak': data['currentStreak'] ?? 0,
          'bestStreak': data['bestStreak'] ?? 0,
          'lastWorkoutDate': data['lastWorkoutDate'],
        };
      }
      return {};
    } catch (e) {
      print('Error getting streak info: $e');
      return {};
    }
  }

  // Set user's chosen plan (e.g., 'home_workouts' -> 7 or 30)
  Future<void> setUserPlanChoice(String planType, int lengthDays) async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final currentData = userDoc.data() as Map<String, dynamic>;
        final planChoices = currentData['planChoices'] ?? {};
        planChoices[planType] = {
          'lengthDays': lengthDays,
          'chosenAt': DateTime.now().toIso8601String(),
        };
        await _writeWithRetry(() async {
          await _firestore.collection('users').doc(userId).update({
            'planChoices': planChoices,
          });
          return null;
        });
      } else {
        await _writeWithRetry(() async {
          await _firestore.collection('users').doc(userId).set({
            'planChoices': {
              planType: {
                'lengthDays': lengthDays,
                'chosenAt': DateTime.now().toIso8601String(),
              },
            },
          }, SetOptions(merge: true));
          return null;
        });
      }
    } catch (e) {
      print('Error setting user plan choice: $e');
    }
  }

  // Get user's chosen plan length for a planType (returns null if not set)
  Future<int?> getUserPlanChoice(String planType) async {
    final userId = _auth.currentUserId;
    if (userId == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      final data = userDoc.data() as Map<String, dynamic>;
      final planChoices = data['planChoices'] as Map<String, dynamic>?;
      if (planChoices == null) return null;
      final choice = planChoices[planType] as Map<String, dynamic>?;
      if (choice == null) return null;
      return (choice['lengthDays'] as num?)?.toInt();
    } catch (e) {
      print('Error getting user plan choice: $e');
      return null;
    }
  }

  // Get user's plan progress map for a planType
  Future<Map<String, dynamic>> getUserPlanProgress(String planType) async {
    final userId = _auth.currentUserId;
    if (userId == null) return {};

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};
      final data = userDoc.data() as Map<String, dynamic>;
      final planProgress = data['planProgress'] ?? {};
      return planProgress[planType] ?? {};
    } catch (e) {
      print('Error getting user plan progress: $e');
      return {};
    }
  }

  // Get recent plan progress entries for the current user and optional planType
  Future<List<Map<String, dynamic>>> getPlanProgressEntries({
    String? planType,
    int limit = 30,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) return [];

    try {
      Query query = _firestore
          .collection('plan_progress')
          .where('userId', isEqualTo: userId);
      if (planType != null)
        query = query.where('planType', isEqualTo: planType);
      final snapshot = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching plan progress entries: $e');
      return [];
    }
  }

  // Record completion of a plan day (e.g., day 3 of a 30-day home workout plan)
  Future<String?> recordPlanDay({
    required String planType,
    required int dayIndex,
    required String dayName,
    required int durationSeconds,
    List<Map<String, dynamic>>? exerciseDetails,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) return 'Not signed in';

    try {
      final durationMinutes = (durationSeconds / 60).ceil();
      final caloriesBurned = _calculateCaloriesBurned(
        planType,
        durationMinutes,
      );
      final now = DateTime.now();

      await _writeWithRetry(() async {
        final docRef = _firestore.collection('plan_progress').doc();
        await docRef.set({
          'id': docRef.id,
          'userId': userId,
          'planType': planType,
          'dayIndex': dayIndex,
          'dayName': dayName,
          'durationSeconds': durationSeconds,
          'caloriesBurned': caloriesBurned,
          'exerciseDetails': exerciseDetails ?? [],
          'timestamp': now.toIso8601String(),
          'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        });
        return null;
      });

      // Also update a simple progress map on the user's document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final currentData = userDoc.data() as Map<String, dynamic>;
        final currentPlans = currentData['planProgress'] ?? {};
        currentPlans[planType] = {
          'currentDay': dayIndex,
          'lastCompletedDate': now.toIso8601String(),
        };

        await _writeWithRetry(() async {
          await _firestore.collection('users').doc(userId).update({
            'planProgress': currentPlans,
          });
          return null;
        });
      }

      // Update global workout stats as well
      await _updateUserStats(1, caloriesBurned);

      return null;
    } catch (e) {
      print('Error recording plan day: $e');
      return 'Error recording plan day: $e';
    }
  }
}
