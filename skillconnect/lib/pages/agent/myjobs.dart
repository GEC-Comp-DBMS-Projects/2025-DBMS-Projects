import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:skillconnect/pages/agent/showreviews.dart'; // ✅ Import your reviews page

// --- Data Model for a Job ---
class AgentJob {
  final String id;
  final String title;
  final String status;
  final Timestamp createdAt;
  final String customerName;

  AgentJob({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.customerName,
  });
}

// --- Main Page Widget ---
class AgentJobsPage extends StatefulWidget {
  const AgentJobsPage({super.key});

  @override
  AgentJobsPageState createState() => AgentJobsPageState();
}

class AgentJobsPageState extends State<AgentJobsPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  Stream<List<AgentJob>>? _jobsStream;

  @override
  void initState() {
    super.initState();
    _setupJobsStream();
  }

  void _setupJobsStream() {
    final agentId = FirebaseAuth.instance.currentUser?.uid;
    if (agentId == null) return;
    _jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .where('agentId', isEqualTo: agentId)
        .where('status', whereIn: ['Completed', 'Cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((jobSnapshot) async {
          List<Future<AgentJob?>> jobFutures = jobSnapshot.docs.map((
            jobDoc,
          ) async {
            try {
              final jobData = jobDoc.data();
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(jobData['userId'])
                  .get();

              if (userDoc.exists) {
                return AgentJob(
                  id: jobDoc.id,
                  title: jobData['title'] ?? 'No Title',
                  status: jobData['status'] ?? 'Unknown',
                  createdAt: jobData['createdAt'] ?? Timestamp.now(),
                  customerName: userDoc.data()?['name'] ?? 'Unknown Customer',
                );
              }
            } catch (e) {
              if (kDebugMode) print("Error processing job: $e");
            }
            return null;
          }).toList();

          final jobs = await Future.wait(jobFutures);
          return jobs.where((job) => job != null).cast<AgentJob>().toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Past Jobs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<AgentJob>>(
        stream: _jobsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains(
              'firestore/failed-precondition',
            )) {
              return _buildIndexErrorState();
            }
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState("You have no past jobs.");
          }

          final pastJobs = snapshot.data!;
          return _buildJobList(pastJobs);
        },
      ),
    );
  }

  Widget _buildJobList(List<AgentJob> jobs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(jobs[index]);
      },
    );
  }

  // ✅ Each card now opens the showreviews.dart page
  Widget _buildJobCard(AgentJob job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShowReviewsPage(jobId: job.id), // ✅ Navigate to reviews page
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ),
                  _buildStatusChip(job.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Customer: ${job.customerName}",
                style: const TextStyle(color: grayBlue),
              ),
              Text(
                "Date: ${DateFormat('d MMM yyyy, h:mm a').format(job.createdAt.toDate())}",
                style: const TextStyle(color: grayBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_history_outlined,
            size: 80,
            color: grayBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: grayBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.orangeAccent),
            SizedBox(height: 20),
            Text(
              'Database Index Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "To filter past jobs, Firestore needs a special index. Please check your debug console for a URL to create it. After creating the index, this page will work correctly.",
              textAlign: TextAlign.center,
              style: TextStyle(color: grayBlue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
