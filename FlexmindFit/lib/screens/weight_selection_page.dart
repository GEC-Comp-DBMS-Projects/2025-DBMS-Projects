import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WeightSelectionPage extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final int age;
  final String gender;
  final double height;

  const WeightSelectionPage({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
  });

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  double _weight = 70.0; // Default weight in kg
  final double _minWeight = 30.0;
  final double _maxWeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF007BFF),
              Color(0xFF0056B3),
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
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      'Step 2 of 3',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'What\'s your weight?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'This helps us calculate your calorie needs',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Weight Display
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_weight.toInt()} kg',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_weight * 2.205).toStringAsFixed(1)} lbs',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Weight Slider
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_minWeight.toInt()} kg',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '${_maxWeight.toInt()} kg',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _weight,
                          min: _minWeight,
                          max: _maxWeight,
                          divisions: (_maxWeight - _minWeight).toInt(),
                          onChanged: (value) {
                            setState(() {
                              _weight = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Continue Button
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/goals-selection', extra: {
                        'email': widget.email,
                        'password': widget.password,
                        'name': widget.name,
                        'age': widget.age,
                        'gender': widget.gender,
                        'height': widget.height,
                        'weight': _weight,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
