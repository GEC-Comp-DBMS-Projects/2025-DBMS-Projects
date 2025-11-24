import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:skillconnect/pages/agent/chat.dart';
import 'package:skillconnect/pages/chatpage.dart';
import 'package:skillconnect/pages/customer/showdetails.dart';
import 'package:skillconnect/pages/worker/profile.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  static const Color darkBlue = Color(0xFF2E4A68);
  static const Color white = Colors.white;

  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];

  final List<String> _labels = ["Dashboard", "Chat", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // curved center bump
          Positioned(
            top: 0,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // main row for icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              bool isSelected = widget.currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: isSelected ? 50 : 45,
                        width: isSelected ? 50 : 45,
                        decoration: BoxDecoration(
                          color: isSelected ? white : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected ? darkBlue : white,
                          size: isSelected ? 28 : 24,
                        ),
                      ),
                      Text(
                        _labels[index],
                        style: TextStyle(
                          color: isSelected
                              ? white
                              : white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const WorkerDashboard(),
      const WorkerChatPage(), // Chat with Agent
      const WorkerProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// --- Worker Dashboard ---
class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  final String? workerId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildAvailabilityToggle(),
          const SizedBox(height: 24),
          _buildNewJobsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(workerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            "Loading...",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          );
        }
        final userName = snapshot.data?.get('name') ?? 'Worker';
        return Text(
          'Hello, $userName 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        );
      },
    );
  }

  Widget _buildAvailabilityToggle() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('workers')
              .doc(workerId)
              .snapshots(),
          builder: (context, snapshot) {
            bool isAvailable = false;
            if (snapshot.hasData) {
              isAvailable = snapshot.data?.get('availability') ?? false;
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Are you available for new jobs?",
                  style: TextStyle(fontSize: 16, color: darkBlue),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    FirebaseFirestore.instance
                        .collection('workers')
                        .doc(workerId)
                        .update({'availability': value});
                  },
                  activeColor: lightBlue,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your New Assignments",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('workerId', isEqualTo: workerId)
              .where('status', isEqualTo: 'Accepted')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: lightBlue),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                "You have no new job assignments.",
                style: TextStyle(color: grayBlue),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return NewJobCard(
                  jobData: doc.data() as Map<String, dynamic>,
                  jobId: doc.id,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// --- Job Card ---
class NewJobCard extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobId;

  const NewJobCard({super.key, required this.jobData, required this.jobId});

  @override
  State<NewJobCard> createState() => _NewJobCardState();
}

class _NewJobCardState extends State<NewJobCard> {
  String _customerName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    try {
      final userId = widget.jobData['userId'];
      if (userId == null) {
        setState(() => _customerName = 'Unknown Customer');
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && mounted) {
        setState(() => _customerName = doc.data()?['name'] ?? 'Customer');
      }
    } catch (e) {
      if (mounted) setState(() => _customerName = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.jobId;
    final title = widget.jobData['title'] ?? 'No Title';
    final timestamp = widget.jobData['createdAt'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
        : 'No date';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            Text("Customer: $_customerName"),
            Text("Assigned On: $date"),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text("View Details"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF63ADF2)), // lightBlue
                  foregroundColor: Color(0xFF63ADF2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShowDetailsPage(jobId: id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Fetch agentId from worker document
                    final workerDoc = await FirebaseFirestore.instance
                        .collection('workers')
                        .doc(widget.jobData['workerId'])
                        .get();
                    final agentId = workerDoc.data()?['agentId'];
                    if (agentId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            workerId: widget.jobData['workerId'],
                            userId: widget.jobData['userId'],
                            customerName: _customerName,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63ADF2),
                  ),
                  child: const Text(
                    "Chat",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(widget.jobId)
                          .update({'status': 'Completed'});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job marked as completed!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Mark Completed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Worker Chat Page (Persistent with Agent) ---
class WorkerChatPage extends StatefulWidget {
  const WorkerChatPage({super.key});

  @override
  State<WorkerChatPage> createState() => _WorkerChatPageState();
}

class _WorkerChatPageState extends State<WorkerChatPage> {
  final String? workerId = FirebaseAuth.instance.currentUser?.uid;
  String? agentId;

  @override
  void initState() {
    super.initState();
    _fetchAgentId();
  }

  Future<void> _fetchAgentId() async {
    final doc = await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .get();
    if (doc.exists) {
      setState(() {
        agentId = doc.data()?['agentId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (agentId == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF63ADF2)),
      );
    }

    return AgentWorkerChatPage(
      agentId: agentId!,
      workerId: workerId!,
      workerName: 'Agent',
    );
  }
}
