import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  // Meditation Sessions Plan
  final List<Map<String, dynamic>> _meditationPlan = [
    {
      'title': 'Mindful Breathing',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.self_improvement,
      'duration': '10 mins',
      'difficulty': 'Beginner',
      'description':
          'Focus on your breath to calm your mind and reduce stress.',
      'steps': [
        {
          'name': 'Find a Comfortable Position',
          'detail': 'Sit or lie down comfortably',
          'duration': '1 min',
        },
        {
          'name': 'Deep Breathing',
          'detail': 'Inhale for 4, hold for 4, exhale for 4',
          'duration': '3 mins',
        },
        {
          'name': 'Mindful Observation',
          'detail': 'Notice your breath without changing it',
          'duration': '4 mins',
        },
        {
          'name': 'Gentle Return',
          'detail': 'Slowly return to normal breathing',
          'duration': '2 mins',
        },
      ],
      'benefits': [
        'Reduces stress and anxiety',
        'Improves focus',
        'Helps with emotional regulation',
      ],
    },
    {
      'title': 'Body Scan Relaxation',
      'color': const Color(0xFF2196F3),
      'icon': Icons.airline_seat_flat,
      'duration': '15 mins',
      'difficulty': 'All Levels',
      'description': 'Progressive relaxation through body awareness.',
      'steps': [
        {
          'name': 'Initial Relaxation',
          'detail': 'Lie down and close your eyes',
          'duration': '2 mins',
        },
        {
          'name': 'Lower Body Scan',
          'detail': 'Focus on toes to hips',
          'duration': '5 mins',
        },
        {
          'name': 'Upper Body Scan',
          'detail': 'Focus on torso to head',
          'duration': '5 mins',
        },
        {
          'name': 'Full Body Awareness',
          'detail': 'Feel your entire body',
          'duration': '3 mins',
        },
      ],
      'benefits': [
        'Reduces muscle tension',
        'Improves sleep quality',
        'Increases body awareness',
      ],
    },
    {
      'title': 'Loving-Kindness Meditation',
      'color': const Color(0xFFE91E63),
      'icon': Icons.favorite,
      'duration': '12 mins',
      'difficulty': 'Intermediate',
      'description': 'Develop compassion for yourself and others.',
      'steps': [
        {
          'name': 'Self-Compassion',
          'detail': 'Direct loving thoughts to yourself',
          'duration': '3 mins',
        },
        {
          'name': 'Loved Ones',
          'detail': 'Extend love to close ones',
          'duration': '3 mins',
        },
        {
          'name': 'Neutral People',
          'detail': 'Include acquaintances',
          'duration': '3 mins',
        },
        {
          'name': 'All Beings',
          'detail': 'Expand to everyone',
          'duration': '3 mins',
        },
      ],
      'benefits': [
        'Increases empathy',
        'Reduces negative emotions',
        'Improves relationships',
      ],
    },
    {
      'title': 'Mindful Walking',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.directions_walk,
      'duration': '15 mins',
      'difficulty': 'All Levels',
      'description': 'Practice mindfulness while walking.',
      'steps': [
        {
          'name': 'Standing Awareness',
          'detail': 'Feel your body standing',
          'duration': '2 mins',
        },
        {
          'name': 'Slow Walking',
          'detail': 'Walk slowly with awareness',
          'duration': '5 mins',
        },
        {
          'name': 'Movement Focus',
          'detail': 'Notice each step mindfully',
          'duration': '5 mins',
        },
        {
          'name': 'Integration',
          'detail': 'Return to normal pace',
          'duration': '3 mins',
        },
      ],
      'benefits': [
        'Combines exercise with mindfulness',
        'Improves balance and coordination',
        'Reduces stress while moving',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Meditation'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9C27B0), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        '🧘‍♂️ Guided Meditation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Find peace and clarity through guided meditation practices.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoChip(
                            'Guided',
                            Icons.headphones,
                            Colors.purple,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip('Timer', Icons.timer, Colors.blue),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            'All Levels',
                            Icons.group,
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Meditation Sessions
                Expanded(
                  child: ListView.builder(
                    itemCount: _meditationPlan.length,
                    itemBuilder: (context, index) {
                      final session = _meditationPlan[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildSessionCard(session),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return GestureDetector(
      onTap: () {
        _showSessionDetails(session);
      },
      child: Container(
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: session['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(session['icon'], color: session['color'], size: 30),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.timer,
                        session['duration'],
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.sort,
                        session['difficulty'],
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${session['duration']} • ${session['difficulty']}'),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(session['description']),
              const SizedBox(height: 16),
              const Text(
                'Steps',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...((session['steps'] as List).map<Widget>(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 12, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              step['detail'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Duration: ${step['duration']}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'Benefits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(session['benefits'] as List<String>).map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(benefit)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGuidedMeditation(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  void _startGuidedMeditation(Map<String, dynamic> session) {
    final steps = List<Map<String, dynamic>>.from(session['steps']);
    int currentStepIndex = 0;
    int remainingSeconds = 0;
    Timer? timer;

    void startTimer(
      int duration,
      void Function() onComplete,
      void Function(void Function()) setLocal,
    ) {
      remainingSeconds = duration;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remainingSeconds <= 1) {
          t.cancel();
          onComplete();
        }
        setLocal(() {
          remainingSeconds = (remainingSeconds - 1).clamp(0, 999);
        });
      });
    }

    int _parseMinutes(String duration) {
      final regex = RegExp(r'(\d+)\s*mins?');
      final match = regex.firstMatch(duration);
      return match != null
          ? int.parse(match.group(1)!) * 60
          : 60; // Default to 60 seconds
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            final currentStep = steps[currentStepIndex];
            final duration = _parseMinutes(currentStep['duration']);

            if (remainingSeconds == 0) {
              startTimer(duration, () {
                if (currentStepIndex < steps.length - 1) {
                  currentStepIndex++;
                  setLocal(() {});
                } else {
                  timer?.cancel();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meditation session completed! 🧘‍♂️✨'),
                      backgroundColor: Color(0xFF9C27B0),
                    ),
                  );
                }
              }, setLocal);
            }

            return AlertDialog(
              title: Text(session['title']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentStep['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentStep['detail'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    value: remainingSeconds / duration,
                    color: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(remainingSeconds / 60).floor()}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${currentStepIndex + 1} of ${steps.length}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('End Session'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel();
    });
  }
}
