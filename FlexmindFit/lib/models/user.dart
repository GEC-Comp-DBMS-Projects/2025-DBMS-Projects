class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String weightGoal;
  final String? profileImage;
  final int workoutsCompleted;
  final int caloriesBurned;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.weightGoal,
    this.profileImage,
    required this.workoutsCompleted,
    required this.caloriesBurned,
  });
}
