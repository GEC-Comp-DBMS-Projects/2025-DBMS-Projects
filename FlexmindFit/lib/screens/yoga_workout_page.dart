
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class YogaWorkoutPage extends StatefulWidget {
  const YogaWorkoutPage({super.key});

  @override
  State<YogaWorkoutPage> createState() => _YogaWorkoutPageState();
}

class _YogaWorkoutPageState extends State<YogaWorkoutPage> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = false;

  String _getExerciseImage(String exerciseName) {
    // Map exercise names to their image paths (including common variations)
    final imageMap = {
      // Yoga poses
      'Bridge Pose': 'assets/images/Bridge Pose.jpg',
      'bridge pose': 'assets/images/Bridge Pose.jpg',
      'Cat-Cow Stretch': 'assets/images/Cat-Cow Stretch.jpg',
      'Cat Cow': 'assets/images/Cat-Cow Stretch.jpg',
      'Cat-Cow': 'assets/images/Cat-Cow Stretch.jpg',
      'cat-cow stretch': 'assets/images/Cat-Cow Stretch.jpg',
      'cat cow': 'assets/images/Cat-Cow Stretch.jpg',
      'Child\'s Pose': 'assets/images/Child\'s Pose.webp',
      'Childs Pose': 'assets/images/Child\'s Pose.webp',
      'child\'s pose': 'assets/images/Child\'s Pose.webp',
      'childs pose': 'assets/images/Child\'s Pose.webp',
      'Cobra Pose': 'assets/images/Cobra Pose.jpg',
      'cobra pose': 'assets/images/Cobra Pose.jpg',
      'cobra': 'assets/images/Cobra Pose.jpg',
      'Downward Dog': 'assets/images/Downward Dog.jpg',
      'downward dog': 'assets/images/Downward Dog.jpg',
      'downward-dog': 'assets/images/Downward Dog.jpg',
      'Final Savasana': 'assets/images/Final savasana.png',
      'Final savasana': 'assets/images/Final savasana.png',
      'Savasana': 'assets/images/Final savasana.png',
      'final savasana': 'assets/images/Final savasana.png',
      'savasana': 'assets/images/Final savasana.png',
      'Mountain Pose': 'assets/images/Mountain Pose.jpg',
      'mountain pose': 'assets/images/Mountain Pose.jpg',
      'mountain': 'assets/images/Mountain Pose.jpg',
      'Pigeon Pose': 'assets/images/Pigeon Pose.jpg',
      'pigeon pose': 'assets/images/Pigeon Pose.jpg',
      'pigeon': 'assets/images/Pigeon Pose.jpg',
      'Seated Forward Bend': 'assets/images/Seated Forward Bend.jpg',
      'seated forward bend': 'assets/images/Seated Forward Bend.jpg',
      'forward bend': 'assets/images/Seated Forward Bend.jpg',
      'Tree Pose': 'assets/images/Tree Pose.jpg',
      'tree pose': 'assets/images/Tree Pose.jpg',
      'tree': 'assets/images/Tree Pose.jpg',
      'Triangle Pose': 'assets/images/Triangle Pose.jpg',
      'triangle pose': 'assets/images/Triangle Pose.jpg',
      'triangle': 'assets/images/Triangle Pose.jpg',
      'Warrior I': 'assets/images/Warrior I.jpg',
      'Warrior 1': 'assets/images/Warrior I.jpg',
      'warrior i': 'assets/images/Warrior I.jpg',
      'warrior 1': 'assets/images/Warrior I.jpg',
      'warrior-i': 'assets/images/Warrior I.jpg',
      'Warrior II': 'assets/images/Warrior II.jpg',
      'Warrior 2': 'assets/images/Warrior II.jpg',
      'warrior ii': 'assets/images/Warrior II.jpg',
      'warrior 2': 'assets/images/Warrior II.jpg',
      'warrior-ii': 'assets/images/Warrior II.jpg',
      'warrior-2': 'assets/images/Warrior II.jpg',
      
      // Rest
      'Rest': 'assets/images/fitness_bg.jpg',
      'rest': 'assets/images/fitness_bg.jpg',
    };

    // Try exact match first
    if (imageMap.containsKey(exerciseName)) {
      return imageMap[exerciseName]!;
    }

    // Try case-insensitive fuzzy matching
    final normalizedExercise = exerciseName.toLowerCase().trim();
    for (var entry in imageMap.entries) {
      final normalizedKey = entry.key.toLowerCase();
      if (normalizedExercise.contains(normalizedKey) || normalizedKey.contains(normalizedExercise)) {
        return entry.value;
      }
    }

    // Return a default image if no match found
    print('No image found for exercise: $exerciseName');
    return 'assets/images/fitness_bg.jpg';
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      exercises = _getYogaExercises();
      isLoading = false;
    });
    _buildSequenceFromExercises();
    setState(() {});
  }

  List<Map<String, dynamic>> _getYogaExercises() {
    return [
      {'name': 'Mountain Pose', 'duration': 60},
      {'name': 'Downward Dog', 'duration': 60},
      {'name': 'Warrior I', 'duration': 60},
      {'name': 'Warrior II', 'duration': 60},
      {'name': 'Triangle Pose', 'duration': 60},
      {'name': 'Tree Pose', 'duration': 60},
      {'name': 'Bridge Pose', 'duration': 60},
      {'name': 'Pigeon Pose', 'duration': 60},
      {'name': 'Seated Forward Bend', 'duration': 60},
      {'name': 'Child\'s Pose', 'duration': 120},
      {'name': 'Final Savasana', 'duration': 300},
    ];
  }

  List<Map<String, dynamic>> sequence = [];
  int currentIndex = 0;
  int remainingSeconds = 0;
  Timer? _seqTimer;
  bool playing = false;

  void _buildSequenceFromExercises() {
    sequence = exercises.map((e) {
      return {
        'name': e['name'] ?? 'Exercise',
        'duration': e['duration'] ?? 60,
        'isRest': e['name'] == 'Rest',
        'calPerMin': 3.0, // Average for Yoga
      };
    }).toList();

    currentIndex = 0;
    remainingSeconds = sequence.isNotEmpty ? sequence[0]['duration'] as int : 0;
  }

  void _startSequence() {
    if (sequence.isEmpty || playing) return;
    setState(() => playing = true);
    _seqTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _onStepComplete();
      }
    });
  }

  void _pauseSequence() {
    _seqTimer?.cancel();
    _seqTimer = null;
    setState(() => playing = false);
  }

  void _resetSequence() {
    _pauseSequence();
    setState(() {
      currentIndex = 0;
      remainingSeconds = sequence.isNotEmpty ? sequence[0]['duration'] as int : 0;
    });
  }

  void _onStepComplete() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    if (currentIndex < sequence.length - 1) {
      setState(() {
        currentIndex++;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    } else {
      _pauseSequence();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yoga Session Complete! 🧘‍♀️'),
          content: const Text('Great job! You have completed your yoga session.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _goToNext() {
    if (currentIndex < sequence.length - 1) {
      setState(() {
        currentIndex++;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    }
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        remainingSeconds = sequence[currentIndex]['duration'] as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Yoga Workout'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Yoga Flow',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercises.length} Poses',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: sequence.isEmpty
                        ? const Center(child: Text('No workout sequence available'))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    _getExerciseImage(sequence[currentIndex]['name']),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.self_improvement, size: 60),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: sequence.isNotEmpty
                                          ? 1 - (remainingSeconds / (sequence[currentIndex]['duration'] as int))
                                          : 0,
                                      strokeWidth: 10,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sequence[currentIndex]['name'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Next Up'),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentIndex < sequence.length - 1
                                            ? sequence[currentIndex + 1]['name']
                                            : '—',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: _goToPrevious,
                                    icon: const Icon(Icons.skip_previous),
                                    iconSize: 36,
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      if (playing) {
                                        _pauseSequence();
                                      } else {
                                        _startSequence();
                                      }
                                    },
                                    child: Icon(
                                      playing ? Icons.pause : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _goToNext,
                                    icon: const Icon(Icons.skip_next),
                                    iconSize: 36,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _resetSequence,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reset'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
