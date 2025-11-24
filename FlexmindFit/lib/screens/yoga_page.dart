 import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class YogaPage extends StatefulWidget {
  const YogaPage({super.key});

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  // Session state (strength-style UI; no Firebase)
  bool _inSession = false;
  bool _isCompleted = false;
  bool _playing = false;
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  List<Map<String, dynamic>> _sequence = [];
  Timer? _timer;

  final List<Map<String, dynamic>> _yogaCategories = [
    {
      'title': 'Morning Yoga',
      'subtitle': 'Start your day with energy',
      'duration': '15-20 min',
      'difficulty': 'Beginner',
      'poses': 8,
      'color': Color(0xFFFF9800),
      'icon': Icons.wb_sunny,
      'description': 'Gentle poses to wake up your body and mind',
    },
    {
      'title': 'Evening Yoga',
      'subtitle': 'Wind down and relax',
      'duration': '20-25 min',
      'difficulty': 'Beginner',
      'poses': 10,
      'color': Color(0xFF673AB7),
      'icon': Icons.nightlight_round,
      'description': 'Calming poses to prepare for rest',
    },
    {
      'title': 'Power Yoga',
      'subtitle': 'Build strength and flexibility',
      'duration': '30-45 min',
      'difficulty': 'Intermediate',
      'poses': 15,
      'color': Color(0xFFE91E63),
      'icon': Icons.fitness_center,
      'description': 'Dynamic flow to build strength',
    },
    {
      'title': 'Yin Yoga',
      'subtitle': 'Deep relaxation and flexibility',
      'duration': '25-40 min',
      'difficulty': 'Beginner',
      'poses': 6,
      'color': Color(0xFF4CAF50),
      'icon': Icons.self_improvement,
      'description': 'Long-held poses for deep stretch',
    },
    {
      'title': 'Meditation',
      'subtitle': 'Mindfulness and inner peace',
      'duration': '10-30 min',
      'difficulty': 'All Levels',
      'poses': 3,
      'color': Color(0xFF2196F3),
      'icon': Icons.psychology,
      'description': 'Guided meditation sessions',
    },
    {
      'title': 'Prenatal Yoga',
      'subtitle': 'Safe practice for expecting mothers',
      'duration': '20-30 min',
      'difficulty': 'Beginner',
      'poses': 8,
      'color': Color(0xFF9C27B0),
      'icon': Icons.favorite,
      'description': 'Gentle poses for pregnancy',
    },
  ];

  final List<Map<String, dynamic>> _yogaPoses = [
    {
      'name': 'Mountain Pose',
      'sanskrit': 'Tadasana',
      'duration': '30-60 seconds',
      'benefits': 'Improves posture, strengthens legs',
      'difficulty': 'Beginner',
      'instructions': 'Stand tall with feet together, arms at sides. Ground through feet, lengthen spine.',
      'image': 'assets/images/Mountain Pose.jpg',
    },
    {
      'name': 'Downward Dog',
      'sanskrit': 'Adho Mukha Svanasana',
      'duration': '30-90 seconds',
      'benefits': 'Strengthens arms, stretches hamstrings',
      'difficulty': 'Beginner',
      'instructions': 'Start on hands and knees, lift hips up and back, straighten legs.',
      'image': 'assets/images/Downward Dog.jpg',
    },
    {
      'name': 'Warrior I',
      'sanskrit': 'Virabhadrasana I',
      'duration': '30-60 seconds',
      'benefits': 'Strengthens legs, opens chest',
      'difficulty': 'Beginner',
      'instructions': 'Step one foot forward, bend knee, raise arms overhead.',
      'image': 'assets/images/Warrior I.jpg',
    },
    {
      'name': 'Tree Pose',
      'sanskrit': 'Vrksasana',
      'duration': '30-60 seconds',
      'benefits': 'Improves balance, strengthens legs',
      'difficulty': 'Beginner',
      'instructions': 'Stand on one leg, place other foot on inner thigh, hands in prayer.',
      'image': 'assets/images/Tree Pose.jpg',
    },
    {
      'name': 'Child\'s Pose',
      'sanskrit': 'Balasana',
      'duration': '30-90 seconds',
      'benefits': 'Relaxes spine, calms mind',
      'difficulty': 'Beginner',
      'instructions': 'Kneel, sit back on heels, fold forward, arms extended.',
      'image': 'assets/images/Child’s Pose.webp',
    },
    {
      'name': 'Cobra Pose',
      'sanskrit': 'Bhujangasana',
      'duration': '15-30 seconds',
      'benefits': 'Strengthens back, opens chest',
      'difficulty': 'Beginner',
      'instructions': 'Lie on stomach, place hands under shoulders, lift chest up.',
      'image': 'assets/images/Cobra Pose.jpg',
    },
    {
      'name': 'Bridge Pose',
      'sanskrit': 'Setu Bandhasana',
      'duration': '30-60 seconds',
      'benefits': 'Strengthens back, glutes, and legs',
      'difficulty': 'Beginner',
      'instructions': 'Lie on your back with knees bent, feet flat on the floor. Lift your hips off the floor.',
      'image': 'assets/images/Bridge Pose.jpg',
    },
    {
      'name': 'Cat-Cow Stretch',
      'sanskrit': 'Marjaryasana-Bitilasana',
      'duration': '60-90 seconds',
      'benefits': 'Warms up the spine, improves flexibility',
      'difficulty': 'Beginner',
      'instructions': 'Start on your hands and knees. Inhale as you drop your belly and look up (Cow). Exhale as you round your spine and tuck your chin (Cat).',
      'image': 'assets/images/Cat-Cow Stretch.jpg',
    },
    {
      'name': 'Pigeon Pose',
      'sanskrit': 'Eka Pada Rajakapotasana',
      'duration': '30-60 seconds per side',
      'benefits': 'Opens hips, stretches thighs and glutes',
      'difficulty': 'Intermediate',
      'instructions': 'From Downward Dog, bring one knee forward between your hands. Extend the other leg back.',
      'image': 'assets/images/Pigeon Pose.jpg',
    },
    {
      'name': 'Seated Forward Bend',
      'sanskrit': 'Paschimottanasana',
      'duration': '30-90 seconds',
      'benefits': 'Stretches hamstrings, back, and shoulders',
      'difficulty': 'Beginner',
      'instructions': 'Sit with legs extended in front of you. Hinge at your hips and fold forward.',
      'image': 'assets/images/Seated Forward Bend.jpg',
    },
    {
      'name': 'Triangle Pose',
      'sanskrit': 'Trikonasana',
      'duration': '30-60 seconds per side',
      'benefits': 'Stretches hamstrings, hips, and spine',
      'difficulty': 'Beginner',
      'instructions': 'Stand with feet wide apart. Turn one foot out and extend the opposite arm up and over.',
      'image': 'assets/images/Triangle Pose.jpg',
    },
    {
      'name': 'Warrior II',
      'sanskrit': 'Virabhadrasana II',
      'duration': '30-60 seconds per side',
      'benefits': 'Strengthens legs, opens hips and shoulders',
      'difficulty': 'Beginner',
      'instructions': 'Stand with feet wide apart. Bend one knee and extend your arms parallel to the floor.',
      'image': 'assets/images/Warrior II.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga & Flexibility'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_inSession) {
              _stopTimer();
              setState(() {
                _inSession = false;
                _isCompleted = false;
              });
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      floatingActionButton: _inSession && !_isCompleted
          ? FloatingActionButton.extended(
              onPressed: _markSessionComplete,
              icon: const Icon(Icons.check),
              label: const Text('Complete Workout'),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _inSession ? _buildSessionView() : _buildCatalogView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogView() {
    return Column(
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
                '🧘 Yoga & Flexibility',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find balance, strength, and inner peace through yoga practice.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip('All Levels', Icons.people, Colors.blue),
                  const SizedBox(width: 12),
                  _buildInfoChip('Flexibility', Icons.accessibility_new, Colors.green),
                  const SizedBox(width: 12),
                  _buildInfoChip('Mindfulness', Icons.psychology, Colors.purple),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Yoga Sessions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: _yogaCategories.length,
            itemBuilder: (context, index) {
              final category = _yogaCategories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildYogaCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionView() {
    final current = _sequence[_currentIndex];
    return Column(
      children: [
        // Image
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              current['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.self_improvement, size: 60),
              ),
            ),
          ),
        ),

        // Progress
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1 - (_remainingSeconds / (current['duration'] as int)),
                strokeWidth: 10,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Next up
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('Next Up'),
                const SizedBox(height: 6),
                Text(
                  _currentIndex < _sequence.length - 1 ? _sequence[_currentIndex + 1]['name'] : '—',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _currentIndex > 0 ? _goPrevious : null,
              icon: const Icon(Icons.skip_previous),
              iconSize: 36,
            ),
            FloatingActionButton(
              onPressed: () {
                if (_playing) {
                  _pauseTimer();
                } else {
                  _startTimer();
                }
              },
              child: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              onPressed: _currentIndex < _sequence.length - 1 ? _goNext : null,
              icon: const Icon(Icons.skip_next),
              iconSize: 36,
            ),
          ],
        ),
      ],
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

  Widget _buildYogaCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _showYogaSessionDetails(category),
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
            // Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  _getCategoryPreviewImage(category['title'] as String),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: category['color'].withOpacity(0.1),
                    alignment: Alignment.center,
                    child: Icon(category['icon'], color: category['color']),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.timer,
                        category['duration'],
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.signal_cellular_alt,
                        category['difficulty'],
                        _getDifficultyColor(category['difficulty']),
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.accessibility_new,
                        '${category['poses']} poses',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryPreviewImage(String title) {
    // Pick a representative pose image for each category
    if (title.contains('Morning')) return 'assets/images/Mountain Pose.jpg';
    if (title.contains('Evening')) return 'assets/images/Child’s Pose.webp';
    if (title.contains('Power')) return 'assets/images/Warrior II.jpg';
    if (title.contains('Yin')) return 'assets/images/Seated Forward Bend.jpg';
    if (title.contains('Meditation')) return 'assets/images/Final savasana.png';
    if (title.contains('Prenatal')) return 'assets/images/Bridge Pose.jpg';
    // Fallback to first pose image
    return _yogaPoses.first['image'] as String;
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showYogaSessionDetails(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category['description']),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Duration: ${category['duration']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Difficulty: ${category['difficulty']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.accessibility_new, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text('Poses: ${category['poses']}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Yoga Poses in this session:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._yogaPoses.take(3).map((pose) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${pose['name']} (${pose['duration']})'),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _beginSessionFromCategory(category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  void _beginSessionFromCategory(Map<String, dynamic> category) {
    // Build a simple sequence from available poses; use fixed seconds per pose
    // Extract first N poses based on category['poses'] when possible
    final count = (category['poses'] is int) ? category['poses'] as int : 8;
    final selected = _yogaPoses.take(count).toList();
    _sequence = [];
    for (final pose in selected) {
      _sequence.add({
        'name': pose['name'],
        'image': pose['image'],
        'duration': 45, // 45s per pose
        'isRest': false,
      });
      if (pose != selected.last) {
        _sequence.add({
          'name': 'Rest',
          'image': 'assets/images/Final savasana.png',
          'duration': 20,
          'isRest': true,
        });
      }
    }

    _currentIndex = 0;
    _remainingSeconds = _sequence.isNotEmpty ? _sequence.first['duration'] as int : 0;
    _isCompleted = false;
    _stopTimer();
    setState(() {
      _inSession = true;
      _playing = false;
    });
  }

  void _startTimer() {
    if (_sequence.isEmpty || _playing) return;
    setState(() => _playing = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onStepComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _playing = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _playing = false;
  }

  void _onStepComplete() async {
    if (_currentIndex < _sequence.length - 1) {
      setState(() {
        _currentIndex++;
        _remainingSeconds = _sequence[_currentIndex]['duration'] as int;
      });
    } else {
      _pauseTimer();
      setState(() {
        _isCompleted = true;
      });
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Workout Complete 🎉'),
          content: Text('Great job! You completed the yoga session.'),
        ),
      );
    }
  }

  void _goNext() {
    if (_currentIndex < _sequence.length - 1) {
      setState(() {
        _currentIndex++;
        _remainingSeconds = _sequence[_currentIndex]['duration'] as int;
      });
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _remainingSeconds = _sequence[_currentIndex]['duration'] as int;
      });
    }
  }

  Future<void> _markSessionComplete() async {
    _pauseTimer();
    setState(() {
      _isCompleted = true;
    });
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Day Completed! 🎉'),
        content: Text('You\'ve completed this yoga session.'),
      ),
    );
    if (!mounted) return;
    setState(() {
      _inSession = false;
    });
  }
}
