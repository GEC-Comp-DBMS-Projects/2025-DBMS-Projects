class WorkoutExercise {
  final String name;
  final int duration; // in seconds
  final String instructions;
  final bool isRest;

  WorkoutExercise({
    required this.name,
    required this.duration,
    required this.instructions,
    this.isRest = false,
  });
}

class Workout {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<WorkoutExercise> exercises;
  final int totalDuration; // in seconds

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.exercises,
    required this.totalDuration,
  });
}

