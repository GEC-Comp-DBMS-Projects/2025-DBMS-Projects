import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class CardioDaysListPage extends StatefulWidget {
  final int totalDays;

  const CardioDaysListPage({super.key, required this.totalDays});

  @override
  State<CardioDaysListPage> createState() => _CardioDaysListPageState();
}

class _CardioDaysListPageState extends State<CardioDaysListPage> {
  int currentCompletedDay = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view your progress')),
        );
        context.go('/login');
      }
      setState(() {
        currentCompletedDay = 0;
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection('cardio_workout')
          .doc('current_progress')
          .get();

      if (snapshot.exists) {
        setState(() {
          currentCompletedDay = snapshot.data()?['last_completed_day'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          currentCompletedDay = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading progress: $e');
      setState(() {
        currentCompletedDay = 0;
        isLoading = false;
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
        title: Text('${widget.totalDays}-Day Cardio Program'),
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
                      Text(
                        'Current Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${currentCompletedDay}/${widget.totalDays} days',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: widget.totalDays,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isCompleted = day <= currentCompletedDay;
                      final isAccessible = day <= currentCompletedDay + 1;

                      return _buildDayCard(
                        context,
                        day: day,
                        isCompleted: isCompleted,
                        isAccessible: isAccessible,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(
    BuildContext context, {
    required int day,
    required bool isCompleted,
    required bool isAccessible,
  }) {
    final color = isCompleted
        ? Colors.green
        : isAccessible
        ? Theme.of(context).primaryColor
        : Colors.grey;

    return Card(
      elevation: isAccessible ? 4 : 1,
      color: isAccessible ? null : Colors.grey[200],
      child: InkWell(
        onTap: isAccessible
            ? () {
                context.go('/cardio-workout/${widget.totalDays}/$day');
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: isCompleted || isAccessible ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day $day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isAccessible ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isAccessible
                    ? Icons.play_circle_fill
                    : Icons.lock,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}