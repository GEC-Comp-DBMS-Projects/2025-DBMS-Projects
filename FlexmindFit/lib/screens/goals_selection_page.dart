import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class GoalsSelectionPage extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;

  const GoalsSelectionPage({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  @override
  State<GoalsSelectionPage> createState() => _GoalsSelectionPageState();
}

class _GoalsSelectionPageState extends State<GoalsSelectionPage> {
  String _selectedGoal = 'Lose Weight';
  String _selectedActivity = 'Moderate';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Lose Weight',
      'subtitle': 'Burn fat and get lean',
      'icon': Icons.trending_down,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Gain Weight',
      'subtitle': 'Build healthy mass',
      'icon': Icons.trending_up,
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Build Muscle',
      'subtitle': 'Get stronger and bigger',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFF9800),
    },
    {
      'title': 'Get Stronger',
      'subtitle': 'Increase your strength',
      'icon': Icons.whatshot,
      'color': Color(0xFFE91E63),
    },
    {
      'title': 'Improve Endurance',
      'subtitle': 'Build cardiovascular fitness',
      'icon': Icons.directions_run,
      'color': Color(0xFF9C27B0),
    },
    {
      'title': 'Maintain Weight',
      'subtitle': 'Stay fit and healthy',
      'icon': Icons.balance,
      'color': Color(0xFF607D8B),
    },
  ];

  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];

  void _completeSetup() async {
    setState(() {
      _isLoading = true;
    });

    // Update user data in Firestore with complete information
    Map<String, dynamic> userDetails = {
      'email': widget.email, // Include email to ensure it's preserved
      'name': widget.name,
      'age': widget.age,
      'gender': widget.gender,
      'height': widget.height,
      'weight': widget.weight,
      'weightGoal': _selectedGoal,
      'activityLevel': _selectedActivity,
      'workoutsCompleted': 0, // Ensure these fields are set
      'caloriesBurned': 0, // Ensure these fields are set
    };

    String? error = await AuthService().updateUserData(userDetails);

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete setup: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                      'Step 3 of 3',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'What\'s your goal?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Choose your primary fitness goal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Goals Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final isSelected = _selectedGoal == goal['title'];
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal['title'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? goal['color'].withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? goal['color']
                                  : Colors.white.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  goal['icon'],
                                  size: 32,
                                  color: isSelected ? goal['color'] : Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? goal['color'] : Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal['subtitle'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? goal['color'] : Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Activity Level
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedActivity,
                        dropdownColor: const Color(0xFF0056B3),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        items: _activityLevels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedActivity = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Complete Setup Button
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF007BFF),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
                            ),
                          )
                        : const Text(
                            'Complete Setup',
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
