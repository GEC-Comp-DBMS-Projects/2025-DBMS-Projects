import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details.dart';

class AgentDetails {
  final String orgName;
  final String profilePicUrl;
  final String contact;
  final String email;
  final String address;
  final String city;
  final double rating;
  final List<String> services;

  AgentDetails({
    required this.orgName,
    required this.profilePicUrl,
    required this.contact,
    required this.email,
    required this.address,
    required this.city,
    required this.rating,
    required this.services,
  });
}

class AgentDetailsPage extends StatefulWidget {
  final String agentId;
  final String selectedService;
  const AgentDetailsPage({
    super.key,
    required this.agentId,
    required this.selectedService,
  });

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  Future<AgentDetails?>? _agentDetailsFuture;

  @override
  void initState() {
    super.initState();
    _agentDetailsFuture = _fetchAgentDetails();
  }

  Future<AgentDetails?> _fetchAgentDetails() async {
    try {
      final userDocFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.agentId)
          .get();
      final agentDocFuture = FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.agentId)
          .get();

      final results = await Future.wait([userDocFuture, agentDocFuture]);
      final userDoc = results[0];
      final agentDoc = results[1];

      if (userDoc.exists && agentDoc.exists) {
        final userData = userDoc.data()!;
        final agentData = agentDoc.data()!;
        return AgentDetails(
          orgName: agentData['orgName'] ?? 'No Name',
          profilePicUrl: userData['profilePicUrl'] ?? '',
          contact: userData['contact'] ?? 'Not provided',
          email: userData['email'] ?? 'Not provided',
          address: userData['address'] ?? 'Not provided',
          city: userData['city'] ?? 'Not provided',
          rating: (agentData['rating']?['average'] ?? 0.0).toDouble(),
          services: List<String>.from(agentData['services'] ?? []),
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching agent details: $e");
      }
      throw Exception("Failed to load agent details.");
    }
  }

  Future<void> _sendJobRequest(String agentName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You must be logged in.")));
      return;
    }

    // --- Confirmation Dialog ---
    bool confirm =
        await showDialog<bool>(
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

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context, rootNavigator: true).pop();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => JobDetailsPage(
              agentId: widget.agentId,
              selectedService: widget.selectedService,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // Ensure loading dialog closes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Agent Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<AgentDetails?>(
        future: _agentDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load agent details."));
          }

          final agent = snapshot.data!;
          final initial = agent.orgName.isNotEmpty
              ? agent.orgName[0].toUpperCase()
              : 'A';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: paleBlue,
                          backgroundImage: agent.profilePicUrl.isNotEmpty
                              ? NetworkImage(agent.profilePicUrl)
                              : null,
                          child: agent.profilePicUrl.isEmpty
                              ? Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: darkBlue,
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
                                  fontSize: 22,
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
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    agent.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
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
                    const Divider(height: 32),
                    // Contact Info
                    _buildInfoRow(Icons.phone_outlined, agent.contact),
                    _buildInfoRow(Icons.email_outlined, agent.email),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "${agent.address}, ${agent.city}",
                    ),
                    const Divider(height: 32),
                    // Services
                    const Text(
                      'All Services Offered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agent.services
                          .map(
                            (service) => Chip(
                              label: Text(service),
                              backgroundColor: lightBlue.withValues(alpha: 0.1),
                              labelStyle: const TextStyle(color: darkBlue),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Bottom button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _sendJobRequest(agent.orgName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send Request for ${widget.selectedService}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: grayBlue, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: darkBlue),
            ),
          ),
        ],
      ),
    );
  }
}
