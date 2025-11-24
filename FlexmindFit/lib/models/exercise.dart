class Exercise {
  final String id;
  final String name;
  final String description;
  final String image;
  final int duration; // in seconds
  final String instructions;
  final String category;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.duration,
    required this.instructions,
    required this.category,
  });
}

class WorkoutCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<Exercise> exercises;

  WorkoutCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.exercises,
  });
}
