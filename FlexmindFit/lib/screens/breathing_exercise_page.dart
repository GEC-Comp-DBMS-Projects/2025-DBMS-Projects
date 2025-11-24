import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreathingExercisePage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const BreathingExercisePage({super.key, required this.exercise});

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage> {
  bool _isExerciseStarted = false;
  bool _isPaused = false;
  Timer? _timer;
  int _currentCycle = 1;
  String _currentPhase = 'Get Ready';
  int _currentPhaseSeconds = 0;
  int _totalPhaseSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isExerciseStarted = true;
      _isPaused = false;
      _startPhase('inhale');
    });
  }

  void _pauseExercise() {
    setState(() {
      _isPaused = true;
      _timer?.cancel();
    });
  }

  void _resumeExercise() {
    setState(() {
      _isPaused = false;
      _startPhase(_currentPhase.toLowerCase());
    });
  }

  void _stopExercise() {
    setState(() {
      _isExerciseStarted = false;
      _isPaused = false;
      _currentCycle = 1;
      _currentPhase = 'Get Ready';
      _currentPhaseSeconds = 0;
      _timer?.cancel();
    });
  }

  void _startPhase(String phase) {
    final exercise = widget.exercise;

    Map<String, String> phaseNames = {
      'inhale': 'Inhale',
      'hold1': 'Hold',
      'exhale': 'Exhale',
      'hold2': 'Rest',
    };

    Map<String, int> phaseDurations = {
      'inhale': exercise['inhale'] as int,
      'hold1': exercise['hold1'] as int,
      'exhale': exercise['exhale'] as int,
      'hold2': exercise['hold2'] as int,
    };

    List<String> phases = ['inhale', 'hold1', 'exhale', 'hold2'];

    void moveToNextPhase() {
      int currentIndex = phases.indexOf(phase);
      String nextPhase;

      if (currentIndex == phases.length - 1) {
        if (_currentCycle >= exercise['cycles']) {
          _completeExercise();
          return;
        }
        setState(() {
          _currentCycle++;
        });
        nextPhase = phases[0];
      } else {
        nextPhase = phases[currentIndex + 1];
      }

      _startPhase(nextPhase);
    }

    setState(() {
      _currentPhase = phaseNames[phase] ?? 'Get Ready';
      _currentPhaseSeconds = phaseDurations[phase] ?? 0;
      _totalPhaseSeconds = phaseDurations[phase] ?? 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPhaseSeconds > 0) {
        setState(() {
          _currentPhaseSeconds--;
        });
      } else {
        timer.cancel();
        moveToNextPhase();
      }
    });
  }

  void _completeExercise() {
    _timer?.cancel();
    setState(() {
      _isExerciseStarted = false;
      _currentPhase = 'Complete';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Complete! 🎉'),
        content: Text(
          'You completed ${widget.exercise['cycles']} cycles of ${widget.exercise['title']}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _stopExercise();
              _startExercise();
            },
            child: const Text('Start Again'),
          ),
        ],
      ),
    );
  }

  String _formatPattern(Map<String, dynamic> exercise) {
    return exercise['pattern'];
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['title']),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Pattern Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Color(0xFF2196F3)),
                            const SizedBox(width: 8),
                            Text(
                              _formatPattern(exercise),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Timer Circle
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _isExerciseStarted
                                ? (_totalPhaseSeconds - _currentPhaseSeconds) /
                                      _totalPhaseSeconds
                                : 0,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            color: _getPhaseColor(_currentPhase),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPhase,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_isExerciseStarted) ...[
                              const SizedBox(height: 8),
                              Text(
                                '$_currentPhaseSeconds',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cycle $_currentCycle of ${exercise['cycles']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!_isExerciseStarted)
                      ElevatedButton.icon(
                        onPressed: _startExercise,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      )
                    else ...[
                      ElevatedButton.icon(
                        onPressed: _isPaused ? _resumeExercise : _pauseExercise,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _stopExercise,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'inhale':
        return Colors.blue;
      case 'hold':
        return Colors.purple;
      case 'exhale':
        return Colors.green;
      case 'rest':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
