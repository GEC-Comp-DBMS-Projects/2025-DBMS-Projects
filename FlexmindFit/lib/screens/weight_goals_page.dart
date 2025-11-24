import 'package:flutter/material.dart';

class WeightGoalsPage extends StatefulWidget {
  const WeightGoalsPage({super.key});

  @override
  State<WeightGoalsPage> createState() => _WeightGoalsPageState();
}

class _WeightGoalsPageState extends State<WeightGoalsPage> {
  int currentWeight = 70; // in kg
  int goalWeight = 65; // in kg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF000000), // Black
              Color(0xFF3B82F6), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Weight Goals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Your weight journey',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Set your current weight and goal weight',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Weight Cards
                Expanded(
                  child: Column(
                    children: [
                      // Current Weight Selector
                      _buildWeightCard(
                        title: 'Current Weight',
                        value: currentWeight,
                        unit: 'kg',
                        onChanged: (value) {
                          setState(() {
                            currentWeight = value;
                            // Ensure goal weight doesn't exceed current weight for weight loss
                            if (goalWeight > currentWeight) {
                              goalWeight = currentWeight;
                            }
                          });
                        },
                        min: 40,
                        max: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 25),

                      // Goal Weight Selector
                      _buildWeightCard(
                        title: 'Goal Weight',
                        value: goalWeight,
                        unit: 'kg',
                        onChanged: (value) {
                          setState(() {
                            goalWeight = value;
                          });
                        },
                        min: 40,
                        max: 150,
                        color: const Color(0xFF3B82F6),
                      ),

                      const SizedBox(height: 20),

                      // Weight Difference Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentWeight > goalWeight
                                  ? Icons.trending_down
                                  : currentWeight < goalWeight
                                  ? Icons.trending_up
                                  : Icons.trending_flat,
                              color: currentWeight > goalWeight
                                  ? Colors.green
                                  : currentWeight < goalWeight
                                  ? Colors.orange
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentWeight == goalWeight
                                  ? 'Maintain current weight'
                                  : currentWeight > goalWeight
                                  ? 'Lose ${currentWeight - goalWeight} kg'
                                  : 'Gain ${goalWeight - currentWeight} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Complete Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile setup complete! Welcome to FlexMind Fit!',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Complete Setup',
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

  Widget _buildWeightCard({
    required String title,
    required int value,
    required String unit,
    required ValueChanged<int> onChanged,
    required int min,
    required int max,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (newValue) {
                onChanged(newValue.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}
