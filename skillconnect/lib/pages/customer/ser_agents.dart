import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/pages/customer/details.dart';
import 'package:skillconnect/pages/customer/sel_agent.dart';

class Agent {
  final String id;
  final String orgName;
  final String profilePicUrl;
  final double rating;

  Agent({
    required this.id,
    required this.orgName,
    required this.profilePicUrl,
    required this.rating,
  });
}

class AvailableAgentsPage extends StatefulWidget {
  final String selectedService;
  const AvailableAgentsPage({super.key, required this.selectedService});

  @override
  State<AvailableAgentsPage> createState() => _AvailableAgentsPageState();
}

class _AvailableAgentsPageState extends State<AvailableAgentsPage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  late Future<List<Agent>> _agentsFuture;

  @override
  void initState() {
    super.initState();
    _agentsFuture = _fetchAvailableAgents();
  }

  Future<List<Agent>> _fetchAvailableAgents() async {
    try {
      final agentQuery = await FirebaseFirestore.instance
          .collection('agents')
          .where('services', arrayContains: widget.selectedService)
          .get();

      if (agentQuery.docs.isEmpty) return [];

      List<Future<Agent?>> agentFutures = agentQuery.docs.map((agentDoc) async {
        final agentId = agentDoc.id;
        final agentData = agentDoc.data();

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(agentId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return Agent(
            id: agentId,
            orgName: agentData['orgName'] ?? 'No Name',
            profilePicUrl: userData['profilePicUrl'] ?? '',
            rating: (agentData['rating']?['average'] ?? 0.0).toDouble(),
          );
        }
        return null;
      }).toList();

      final agents = await Future.wait(agentFutures);
      return agents.where((a) => a != null).cast<Agent>().toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching agents: $e");
      }
      throw Exception(
        "Failed to load agents. Please check your Firestore Rules and Indexes.",
      );
    }
  }

  Future<void> _sendJobRequest(String agentId, String agentName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to send a request."),
        ),
      );
      return;
    }

    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Job Request'),
            content: Text(
              'Send a request to "$agentName" for "${widget.selectedService}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Send'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Directly navigate to JobDetailsPage — no Firestore write here
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JobDetailsPage(
          agentId: agentId,
          selectedService: widget.selectedService,
        ),
      ),
    );

    // Show feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to job details...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Available Agents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Agent>>(
        future: _agentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final agents = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              return _buildAgentCard(agents[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAgentCard(Agent agent) {
    final initial = agent.orgName.isNotEmpty
        ? agent.orgName[0].toUpperCase()
        : 'A';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgentDetailsPage(
              agentId: agent.id,
              selectedService: widget.selectedService,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: paleBlue,
                    backgroundImage: agent.profilePicUrl.isNotEmpty
                        ? NetworkImage(agent.profilePicUrl)
                        : null,
                    child: agent.profilePicUrl.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              color: darkBlue,
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.orgName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              agent.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: grayBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _sendJobRequest(agent.id, agent.orgName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Send Request',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
            Icons.search_off,
            size: 80,
            color: grayBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Agents Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'We couldn\'t find any available agents for "${widget.selectedService}" right now.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: grayBlue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Something Went Wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Could not load agents. Please ensure you have created the required 'services' index in Firestore.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: grayBlue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
