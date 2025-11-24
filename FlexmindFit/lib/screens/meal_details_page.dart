import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/dummy_data.dart';
import '../models/meal.dart';

class MealDetailsPage extends StatelessWidget {
  final String mealId;
  
  const MealDetailsPage({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    // Find the meal from all categories
    final dietCategories = DummyData.getDietCategories();
    Meal? meal;
    for (final category in dietCategories) {
      try {
        meal = category.meals.firstWhere((m) => m.id == mealId);
        break;
      } catch (e) {
        continue;
      }
    }
    
    if (meal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meal Not Found')),
        body: const Center(child: Text('Meal not found')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/diet-plans'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Image Banner
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Color(0xFF007BFF),
                    size: 80,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Meal Name and Calories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${meal.calories} kcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ingredients Section
                _buildSection(
                  title: 'Ingredients',
                  icon: Icons.list,
                  child: Column(
                    children: meal.ingredients.map((ingredient) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF007BFF),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              ingredient,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Nutritional Breakdown
                _buildSection(
                  title: 'Nutritional Breakdown',
                  icon: Icons.analytics,
                  child: Row(
                    children: [
                      _buildNutritionCard('Protein', '${meal.nutrition['protein']!.toStringAsFixed(1)}g', Icons.fitness_center),
                      const SizedBox(width: 16),
                      _buildNutritionCard('Carbs', '${meal.nutrition['carbs']!.toStringAsFixed(1)}g', Icons.grain),
                      const SizedBox(width: 16),
                      _buildNutritionCard('Fats', '${meal.nutrition['fats']!.toStringAsFixed(1)}g', Icons.opacity),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Preparation Tips
                _buildSection(
                  title: 'Preparation Tips',
                  icon: Icons.lightbulb,
                  child: Text(
                    meal.preparationTips,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Add to My Plan Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to your meal plan!'),
                          backgroundColor: Color(0xFF007BFF),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add to My Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007BFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF007BFF), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007BFF),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
