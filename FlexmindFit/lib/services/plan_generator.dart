List<Map<String, dynamic>> generatePlan(String planType, int days) {
  final strengthPool = [
    {'name': 'Push-ups', 'duration': 45},
    {'name': 'Squats', 'duration': 45},
    {'name': 'Lunges', 'duration': 40},
    {'name': 'Plank', 'duration': 40},
    {'name': 'Glute Bridges', 'duration': 40},
  ];

  final cardioPool = [
    {'name': 'Jumping Jacks', 'duration': 45},
    {'name': 'Burpees', 'duration': 35},
    {'name': 'High Knees', 'duration': 40},
    {'name': 'Mountain Climbers', 'duration': 35},
    {'name': 'Skater Jumps', 'duration': 35},
  ];

  final homePool = [
    {'name': 'Bodyweight Squats', 'duration': 45},
    {'name': 'Push-ups', 'duration': 40},
    {'name': 'Plank Shoulder Taps', 'duration': 40},
    {'name': 'Jump Squats', 'duration': 35},
    {'name': 'Rest', 'duration': 30, 'isRest': true},
  ];

  final pool = planType == 'cardio_workouts'
      ? cardioPool
      : planType == 'strength_training'
      ? strengthPool
      : homePool;

  final List<Map<String, dynamic>> daysList = [];
  for (int i = 0; i < days; i++) {
    final int rounds = 2 + (i ~/ (days / 3 + 0.5)).clamp(0, 3);
    final dayExercises = pool.map((e) => Map<String, dynamic>.from(e)).toList();

    final factor = 1 + (i / (days - 1)) * 0.5; // up to +50% duration
    for (var ex in dayExercises) {
      ex['duration'] = (ex['duration'] * factor).round();
    }

    daysList.add({
      'index': i + 1,
      'title': 'Day ${i + 1}',
      'rounds': rounds,
      'exercises': dayExercises,
    });
  }

  return daysList;
}
