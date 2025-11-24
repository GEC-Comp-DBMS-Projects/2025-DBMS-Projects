import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/pages/agent/chat.dart'; // Make sure this page exists

// --- Data Model for a Worker ---
class Worker {
  final String id;
  final String name;
  final String email;
  final String profilePicUrl;
  final List<String> services;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicUrl,
    required this.services,
  });
}

// --- Main Page Widget ---
class MyWorkersPage extends StatefulWidget {
  const MyWorkersPage({super.key});

  @override
  _MyWorkersPageState createState() => _MyWorkersPageState();
}

class _MyWorkersPageState extends State<MyWorkersPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  Stream<List<Worker>>? _workersStream;

  @override
  void initState() {
    super.initState();
    _setupWorkersStream();
  }

  void _setupWorkersStream() {
    final agentId = FirebaseAuth.instance.currentUser?.uid;
    if (agentId == null) return;

    _workersStream = FirebaseFirestore.instance
        .collection('workers')
        .where('agentId', isEqualTo: agentId)
        .snapshots()
        .asyncMap((workerSnapshot) async {
          List<Future<Worker?>> workerFutures = workerSnapshot.docs.map((
            workerDoc,
          ) async {
            try {
              final workerId = workerDoc.id;
              final workerData = workerDoc.data();

              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(workerId)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;
                return Worker(
                  id: workerId,
                  name: userData['name'] ?? 'No Name',
                  email: userData['email'] ?? 'No Email',
                  profilePicUrl: userData['profilePicUrl'] ?? '',
                  services: List<String>.from(workerData['services'] ?? []),
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print("Error fetching worker details: $e");
              }
            }
            return null;
          }).toList();

          final workers = await Future.wait(workerFutures);
          return workers.where((w) => w != null).cast<Worker>().toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'My Workers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Worker>>(
        stream: _workersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final workers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return _buildWorkerCard(worker);
            },
          );
        },
      ),
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    final initial = worker.name.isNotEmpty ? worker.name[0].toUpperCase() : 'W';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: paleBlue,
              backgroundImage: worker.profilePicUrl.isNotEmpty
                  ? NetworkImage(worker.profilePicUrl)
                  : null,
              child: worker.profilePicUrl.isEmpty
                  ? Text(
                      initial,
                      style: const TextStyle(fontSize: 24, color: darkBlue),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          worker.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AgentWorkerChatPage(
                                agentId: FirebaseAuth.instance.currentUser!.uid,
                                workerId: worker.id,
                                workerName: worker.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                        ),
                        child: const Text(
                          "Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Text(worker.email, style: const TextStyle(color: grayBlue)),
                  const SizedBox(height: 8),
                  if (worker.services.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: worker.services
                          .take(3)
                          .map(
                            (service) => Chip(
                              label: Text(service),
                              backgroundColor: lightBlue.withValues(alpha: 0.1),
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                color: darkBlue,
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: grayBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Workers Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the "Add Worker" button on your profile\nto build your team.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
