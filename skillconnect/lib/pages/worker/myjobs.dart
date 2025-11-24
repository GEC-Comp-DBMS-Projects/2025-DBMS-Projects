import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/pages/worker/jobdetails.dart';

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  late final String? _workerId;

  @override
  void initState() {
    super.initState();
    _workerId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_workerId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your jobs.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'Past Jobs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('workerId', isEqualTo: _workerId)
            .where('status', isEqualTo: 'completed')
            .orderBy('completedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }

          if (snapshot.hasError) {
            if (kDebugMode) print("Error fetching jobs: ${snapshot.error}");
            return const Center(child: Text("Something went wrong."));
          }

          final jobs = snapshot.data?.docs ?? [];

          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                "No completed jobs yet.",
                style: TextStyle(color: grayBlue),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>;
              return _buildJobCard(job);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final title = job['title'] ?? 'Untitled Job';
    final description = job['description'] ?? 'No description provided.';
    final city = job['city'] ?? 'Unknown';
    final budget = job['budget'] ?? 'N/A';
    final date = (job['completedAt'] != null)
        ? (job['completedAt'] as Timestamp).toDate()
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerJobDetailsPage(jobData: job),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: grayBlue),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: lightBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: const TextStyle(color: darkBlue, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: lightBlue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        budget.toString(),
                        style: const TextStyle(
                          color: darkBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (date != null)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Completed on ${date.day}/${date.month}/${date.year}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
