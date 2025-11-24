import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';
import 'progress_tracker_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  Timer? _breathTimer;
  Duration _musicPosition = Duration.zero;
  Duration _musicDuration = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  int _currentTrackIndex = -1;
  final List<Map<String, String>> _soothingTracks = const [
    {
      'title': 'Peaceful Rain',
      'artist': 'Nature Sounds',
      'description': 'Gentle rain for deep relaxation',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'title': 'Ocean Waves',
      'artist': 'Calm Ambience',
      'description': 'Soothing ocean waves for meditation',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
    {
      'title': 'Forest Stream',
      'artist': 'Nature Therapy',
      'description': 'Flowing water in a peaceful forest',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    },
    {
      'title': 'Zen Meditation',
      'artist': 'Mindfulness Music',
      'description': 'Calming tones for meditation',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Setup audio listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _musicDuration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _musicPosition = p);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _nextTrack(auto: true);
    });
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatCalories(int calories) {
    if (calories >= 1000) {
      return '${(calories / 1000).toStringAsFixed(1)}K';
    }
    return calories.toString();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data from Firestore...');
      final data = await AuthService().getUserData();

      if (data == null) {
        print(
          '⚠️ User data is null after loading. Check console logs for Firebase errors.',
        );
      } else {
        print('✓ User data loaded successfully: ${data.keys}');
      }

      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('✗ Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _userData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? _buildHomeContent()
          : IndexedStack(
              index: _currentIndex - 1,
              children: [ProfilePage(), ProgressTrackerPage(), SettingsPage()],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007BFF), Color(0xFF0056B3), Color(0xFFE3F2FD)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Welcome Section with Parallax Effect
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Welcome Section
                    _buildEnhancedWelcomeSection(),
                  ],
                ),
              ),
            ),

            // Physical Health Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      'Physical Health',
                      Icons.fitness_center,
                      const Color(0xFFFF5722),
                    ),
                    const SizedBox(height: 16),
                    _buildPhysicalHealthSection(),
                  ],
                ),
              ),
            ),

            // Mental Health Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      'Mental Health',
                      Icons.psychology,
                      const Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 16),
                    _buildMentalHealthSection(),
                  ],
                ),
              ),
            ),

            // Nutrition Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      'Nutrition & Wellness',
                      Icons.restaurant,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    _buildNutritionSection(),
                  ],
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007BFF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${_userData?['name'] ?? 'User'}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to achieve your fitness goals?',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  'Workouts',
                  (_userData?['workoutsCompleted'] ?? 0).toString(),
                  Icons.fitness_center,
                  const Color(0xFFFF5722),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatCard(
                  'Calories',
                  _formatCalories(_userData?['caloriesBurned'] ?? 0),
                  Icons.local_fire_department,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, [Color? color]) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF007BFF)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? const Color(0xFF007BFF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalHealthSection() {
    return Column(
      children: [
        _buildMainCard(
          title: 'Strength Training',
          subtitle: 'Build muscle and power',
          icon: '💪',
          color: const Color(0xFFFF5722),
          onTap: () => context.go('/strength-plan-selection'),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Cardio Workouts',
          subtitle: 'Burn calories and improve endurance',
          icon: '❤️',
          color: const Color(0xFFE91E63),
          onTap: () => context.go('/cardio-plan-selection'),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Home Workouts',
          subtitle: 'No equipment needed',
          icon: '🏠',
          color: const Color(0xFF9C27B0),
          onTap: () => context.go('/home-plan-selection'),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Yoga & Flexibility',
          subtitle: 'Improve flexibility and balance',
          icon: '🧘',
          color: const Color(0xFF4CAF50),
          onTap: () => context.go('/yoga-workout'),
        ),
      ],
    );
  }

  Widget _buildMentalHealthSection() {
    return Column(
      children: [
        _buildMainCard(
          title: 'Meditation',
          subtitle: 'Find inner peace and calm',
          icon: '🧘‍♀️',
          color: const Color(0xFF9C27B0),
          onTap: () => _showMeditationOptions(),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Breathing Exercises',
          subtitle: 'Reduce stress and anxiety',
          icon: '🌬️',
          color: const Color(0xFF2196F3),
          onTap: () => _showBreathingExercises(),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Sleep Stories',
          subtitle: 'Relaxing stories for better sleep',
          icon: '😴',
          color: const Color(0xFF673AB7),
          onTap: () => _showSleepStories(),
        ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Column(
      children: [
        _buildMainCard(
          title: 'Meal Plans',
          subtitle: 'Healthy recipes for your goals',
          icon: '🍎',
          color: const Color(0xFF4CAF50),
          onTap: () => context.go('/diet-plans'),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Soothing Music',
          subtitle: 'Relax with calming melodies',
          icon: '🎵',
          color: const Color(0xFF9C27B0),
          onTap: () => _showSoothingMusic(),
        ),
        const SizedBox(height: 12),
        _buildMainCard(
          title: 'Progress Tracker',
          subtitle: 'Monitor your fitness journey',
          icon: '📊',
          color: const Color(0xFFFF9800),
          onTap: () => _showProgressTracker(),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMeditationOptions() {
    context.go('/meditation');
  }

  void _showBreathingExercises() {
    final List<Map<String, dynamic>> exercises = [
      {
        'title': 'Box Breathing',
        'pattern': '4-4-4-4',
        'description': 'Inhale 4s • Hold 4s • Exhale 4s • Hold 4s',
        'inhale': 4,
        'hold1': 4,
        'exhale': 4,
        'hold2': 4,
        'cycles': 4,
      },
      {
        'title': '4-7-8 Breathing',
        'pattern': '4-7-8',
        'description': 'Inhale 4s • Hold 7s • Exhale 8s',
        'inhale': 4,
        'hold1': 7,
        'exhale': 8,
        'hold2': 0,
        'cycles': 4,
      },
      {
        'title': 'Coherent Breathing',
        'pattern': '5-5',
        'description': 'Inhale 5s • Exhale 5s',
        'inhale': 5,
        'hold1': 0,
        'exhale': 5,
        'hold2': 0,
        'cycles': 6,
      },
      {
        'title': 'Calm Breathing',
        'pattern': '4-6',
        'description': 'Inhale 4s • Exhale 6s',
        'inhale': 4,
        'hold1': 0,
        'exhale': 6,
        'hold2': 0,
        'cycles': 6,
      },
      {
        'title': 'Deep Relaxation',
        'pattern': '6-2-6',
        'description': 'Deep inhale 6s • Rest 2s • Long exhale 6s',
        'inhale': 6,
        'hold1': 2,
        'exhale': 6,
        'hold2': 0,
        'cycles': 5,
      },
      {
        'title': 'Energy Boost',
        'pattern': '2-0-2',
        'description': 'Quick, energizing breaths with no holds',
        'inhale': 2,
        'hold1': 0,
        'exhale': 2,
        'hold2': 0,
        'cycles': 10,
      },
      {
        'title': 'Alternate Nostril',
        'pattern': '4-4-4-4',
        'description': 'Traditional yogic breathing for balance',
        'inhale': 4,
        'hold1': 4,
        'exhale': 4,
        'hold2': 4,
        'cycles': 5,
      },
      {
        'title': 'Ocean Breath',
        'pattern': '5-0-7',
        'description': 'Ujjayi breathing with extended exhale',
        'inhale': 5,
        'hold1': 0,
        'exhale': 7,
        'hold2': 0,
        'cycles': 6,
      },
      {
        'title': 'Progressive Relaxation',
        'pattern': '7-4-8',
        'description': 'Long breaths for deep relaxation',
        'inhale': 7,
        'hold1': 4,
        'exhale': 8,
        'hold2': 0,
        'cycles': 4,
      },
      {
        'title': 'Lion\'s Breath',
        'pattern': '4-0-2',
        'description': 'Energetic exhale with stress release',
        'inhale': 4,
        'hold1': 0,
        'exhale': 2,
        'hold2': 0,
        'cycles': 6,
      },
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Breathing Exercises'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(ex['title']),
                      subtitle: Text(
                        '${ex['description']} • ${ex['cycles']} cycles',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/breathing-exercise', extra: ex);
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _breathTimer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSleepStories() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Stories'),
        content: const Text(
          'Choose a relaxing story to help you fall asleep faster.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting sleep story...')),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showSoothingMusic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.music_note, color: Color(0xFF9C27B0)),
            const SizedBox(width: 8),
            const Text('Soothing Music'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _soothingTracks.length,
            itemBuilder: (context, index) {
              final music = _soothingTracks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9C27B0).withOpacity(0.1),
                      const Color(0xFF9C27B0).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFF9C27B0),
                      size: 32,
                    ),
                  ),
                  title: Text(
                    music['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music['artist']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        music['description']!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _playTrackAt(index);
                    _openMusicPlayer(currentIndex: index);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProgressTracker() {
    context.go('/progress-tracker');
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Future<void> _playUrl(String url, String title) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlaying = title;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _playTrackAt(int index) async {
    if (index < 0 || index >= _soothingTracks.length) return;
    final track = _soothingTracks[index];
    setState(() {
      _currentTrackIndex = index;
    });
    await _playUrl(track['url']!, track['title']!);
  }

  Future<void> _nextTrack({bool auto = false}) async {
    if (_soothingTracks.isEmpty) return;
    int next = _currentTrackIndex + 1;
    if (next >= _soothingTracks.length) {
      next = 0;
    }
    await _playTrackAt(next);
  }

  Future<void> _previousTrack() async {
    if (_soothingTracks.isEmpty) return;
    int prev = _currentTrackIndex - 1;
    if (prev < 0) {
      prev = _soothingTracks.length - 1;
    }
    await _playTrackAt(prev);
  }

  void _openMusicPlayer({required int currentIndex}) async {
    setState(() {
      _currentTrackIndex = currentIndex;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final current =
                (_currentTrackIndex >= 0 &&
                        _currentTrackIndex < _soothingTracks.length)
                    ? _soothingTracks[_currentTrackIndex]
                    : null;
            final title = current?['title'] ?? 'Now Playing';
            final artist = current?['artist'] ?? '';
            final description = current?['description'] ?? '';
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFF9C27B0)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
                ],
              ),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artist, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _musicPosition.inMilliseconds
                          .clamp(0, _musicDuration.inMilliseconds)
                          .toDouble(),
                      min: 0,
                      max: _musicDuration.inMilliseconds.toDouble() == 0
                          ? 1
                          : _musicDuration.inMilliseconds.toDouble(),
                      onChanged: (v) async {
                        final newPos = Duration(milliseconds: v.toInt());
                        await _audioPlayer.seek(newPos);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_musicPosition)),
                        Text(_formatDuration(_musicDuration)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Color(0xFF9C27B0),
                          ),
                          onPressed: () async {
                            await _previousTrack();
                            setLocalState(() {});
                          },
                          tooltip: 'Previous',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(
                            Icons.stop_circle,
                            color: Color(0xFF9C27B0),
                          ),
                          onPressed: () async {
                            await _audioPlayer.stop();
                          },
                          tooltip: 'Stop',
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          iconSize: 44,
                          icon: Icon(
                            _playerState == PlayerState.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: const Color(0xFF9C27B0),
                          ),
                          onPressed: () async {
                            if (_playerState == PlayerState.playing) {
                              await _audioPlayer.pause();
                            } else {
                              await _audioPlayer.resume();
                            }
                          },
                          tooltip: _playerState == PlayerState.playing
                              ? 'Pause'
                              : 'Play',
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(
                            Icons.skip_next,
                            color: Color(0xFF9C27B0),
                          ),
                          onPressed: () async {
                            await _nextTrack();
                            setLocalState(() {});
                          },
                          tooltip: 'Next',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _audioPlayer.stop();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}