import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:skillconnect/pages/chatpage.dart';
import 'package:skillconnect/pages/customer/review.dart';
import 'package:skillconnect/pages/customer/showdetails.dart';

class Job {
  final String id;
  final String title;
  final String status;
  final Timestamp createdAt;
  final String? agentId;
  final String? workerId;

  Job({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.agentId,
    this.workerId,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      status: data['status'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      agentId: data['agentId'],
      workerId: data['workerId'],
    );
  }
}

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'My Jobs',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkBlue,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: lightBlue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Ongoing'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('userId', isEqualTo: currentUserId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: lightBlue),
              );
            }
            if (snapshot.hasError) {
              return _buildIndexErrorState();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState("You haven't requested any jobs yet.");
            }

            final jobs = snapshot.data!.docs
                .map((doc) => Job.fromFirestore(doc))
                .toList();

            final ongoingJobs = jobs
                .where(
                  (job) =>
                      job.status.toLowerCase() == 'inprogress' ||
                      job.status.toLowerCase() == 'accepted',
                )
                .toList();

            final pendingJobs = jobs
                .where((job) => job.status.toLowerCase() == 'pending')
                .toList();

            final completedJobs = jobs
                .where((job) => job.status.toLowerCase() == 'completed')
                .toList();

            return TabBarView(
              children: [
                _buildJobsList(ongoingJobs, 'No ongoing jobs found.'),
                _buildJobsList(pendingJobs, 'No pending jobs found.'),
                _buildJobsList(completedJobs, 'No completed jobs found.'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobsList(List<Job> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: grayBlue, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return GestureDetector(
          onTap: () {
            if (job.status.toLowerCase() == 'pending') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowDetailsPage(jobId: job.id),
                ),
              );
            }
          },
          child: JobCard(job: job),
        );
      },
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
              "To see your jobs, a Firestore index is needed. Please check your debug console for a URL to create it, or create it manually.",
              textAlign: TextAlign.center,
              style: TextStyle(color: grayBlue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatefulWidget {
  final Job job;
  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  String? _agentName;
  String? _workerName;
  bool _hasReview = false; // ✅ Track if review exists

  static const Color darkBlue = Color(0xFF304D6D);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color lightBlue = Color(0xFF63ADF2);

  @override
  void initState() {
    super.initState();
    _fetchNames();
    _checkIfReviewExists();
  }

  Future<void> _fetchNames() async {
    if (widget.job.agentId != null && widget.job.agentId!.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.job.agentId)
          .get();
      if (doc.exists && mounted) {
        setState(() => _agentName = doc.data()?['orgName'] ?? 'Agent');
      }
    } else {
      _agentName = 'Not assigned';
    }

    if (widget.job.workerId != null && widget.job.workerId!.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.job.workerId)
          .get();
      if (doc.exists && mounted) {
        setState(() => _workerName = doc.data()?['name'] ?? 'Worker');
      }
    }
  }

  Future<void> _checkIfReviewExists() async {
    if (widget.job.workerId != null) {
      final reviewDoc = await FirebaseFirestore.instance
          .collection('reviews')
          .where('jobId', isEqualTo: widget.job.id)
          .where('workerId', isEqualTo: widget.job.workerId)
          .get();

      if (mounted && reviewDoc.docs.isNotEmpty) {
        setState(() {
          _hasReview = true;
        });
      }
    }
  }

  void _navigateToChat() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (widget.job.workerId == null ||
        _workerName == null ||
        currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Worker information not available for chat."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          workerId: widget.job.workerId!,
          userId: currentUser.uid,
          customerName: _workerName!,
        ),
      ),
    );
  }

  void _navigateToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPage(
          jobId: widget.job.id,
          workerId: widget.job.workerId!,
          workerName: _workerName ?? 'Worker',
          isEditing: _hasReview, // optional: handle edit mode in ReviewPage
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'inprogress':
        return Colors.lightBlue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canChat = [
      'accepted',
      'inprogress',
    ].contains(widget.job.status.toLowerCase());

    final isCompleted = widget.job.status.toLowerCase() == 'completed';

    return Card(
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
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                Chip(
                  label: Text(widget.job.status),
                  backgroundColor: _getStatusColor(
                    widget.job.status,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getStatusColor(widget.job.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              DateFormat('d MMM yyyy').format(widget.job.createdAt.toDate()),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline, _agentName ?? 'Loading...'),
            if (canChat) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat with Worker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navigateToReview,
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: Text(
                    _hasReview ? 'Edit your Review' : 'Provide a Review',
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: lightBlue),
                    foregroundColor: lightBlue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: grayBlue),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: grayBlue)),
      ],
    );
  }
}
