class WorkoutSession {
  final String id;
  final String userId;
  final String workoutName;
  final String workoutId;
  final int duration; // in seconds
  final int caloriesBurned;
  final DateTime timestamp;
  final DateTime date; // Just the date without time

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutName,
    required this.workoutId,
    required this.duration,
    required this.caloriesBurned,
    required this.timestamp,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workoutName': workoutName,
      'workoutId': workoutId,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
      'date': date.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      userId: map['userId'],
      workoutName: map['workoutName'],
      workoutId: map['workoutId'],
      duration: map['duration'],
      caloriesBurned: map['caloriesBurned'],
      timestamp: DateTime.parse(map['timestamp']),
      date: DateTime.parse(map['date']),
    );
  }
}

