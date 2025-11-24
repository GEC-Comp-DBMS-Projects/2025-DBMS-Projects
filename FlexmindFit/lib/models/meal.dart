class Meal {
  final String id;
  final String name;
  final String image;
  final int calories;
  final List<String> ingredients;
  final Map<String, double> nutrition;
  final String preparationTips;
  final String category;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    required this.calories,
    required this.ingredients,
    required this.nutrition,
    required this.preparationTips,
    required this.category,
  });
}

class DietCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<Meal> meals;

  DietCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.meals,
  });
}
