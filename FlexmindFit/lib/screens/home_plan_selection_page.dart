import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class HomePlanSelectionPage extends StatelessWidget {
  const HomePlanSelectionPage({super.key});

  void _handlePlanSelection(BuildContext context, int days) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to select a plan')),
        );
        context.go('/login');
      }
      return;
    }

    try {
      // Save selection to Firestore with authenticated uid
      await FirebaseFirestore.instance.collection('user_plans').add({
        'type': 'home',
        'days': days,
        'startDate': DateTime.now(),
        'userId': uid,
      });

      if (context.mounted) {
        // Navigate to the days list page for the selected plan
        context.go('/home-days/$days');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Home Workout Plan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Home Workout Duration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildPlanCard(
              context,
              days: 7,
              title: '7 Days Home Challenge',
              description: 'Perfect for beginners to start at home',
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              days: 30,
              title: '30 Days Home Transform',
              description: 'Complete home fitness transformation',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required int days,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => _handlePlanSelection(context, days),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}