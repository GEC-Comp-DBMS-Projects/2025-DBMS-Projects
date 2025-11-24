import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/workout_service.dart';

class PlanSelectionPage extends StatelessWidget {
  final String planType;

  const PlanSelectionPage({super.key, required this.planType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(planType.replaceAll('_', ' ').toUpperCase())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose your plan length',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlanOption(
                  context,
                  days: 7,
                  title: '7-Day Plan',
                  subtitle: 'Perfect for getting started',
                  icon: Icons.rocket_launch,
                ),
                const SizedBox(width: 20),
                _buildPlanOption(
                  context,
                  days: 30,
                  title: '30-Day Plan',
                  subtitle: 'For serious transformation',
                  icon: Icons.fitness_center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required int days,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        // Save user's choice
        await WorkoutService().setUserPlanChoice(planType, days);
        // Navigate to plan page with the choice
        context.go(
          '/plan',
          extra: {'planType': planType, 'selectedLength': days},
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
