import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/pages/agent/add_worker.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  AgentProfilePageState createState() => AgentProfilePageState();
}

class AgentProfilePageState extends State<AgentProfilePage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  Map<String, dynamic>? _agentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgentData();
  }

  Future<void> _fetchAgentData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final userDocFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final agentDocFuture = FirebaseFirestore.instance
          .collection('agents')
          .doc(user.uid)
          .get();

      final List<DocumentSnapshot> results = await Future.wait([
        userDocFuture,
        agentDocFuture,
      ]);

      final userDoc = results[0];
      final agentDoc = results[1];

      if (userDoc.exists && agentDoc.exists && mounted) {
        setState(() {
          _agentData = {
            ...userDoc.data() as Map<String, dynamic>,
            ...agentDoc.data() as Map<String, dynamic>,
          };
        });
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print("Error fetching agent data: $e");
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lightBlue))
          : _agentData == null
          ? const Center(child: Text("Could not load profile data."))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final name = _agentData?['name'] ?? 'No Name';
    final email = _agentData?['email'] ?? 'No Email';
    final profilePicUrl = _agentData?['profilePicUrl'] ?? '';
    final services = List<String>.from(_agentData?['services'] ?? []);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: paleBlue,
            backgroundImage: profilePicUrl.isNotEmpty
                ? NetworkImage(profilePicUrl)
                : null,
            child: profilePicUrl.isEmpty
                ? Text(
                    initial,
                    style: const TextStyle(color: darkBlue, fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          Text(email, style: const TextStyle(fontSize: 14, color: grayBlue)),
          const SizedBox(height: 30),

          _buildInfoCard(),
          const SizedBox(height: 20),

          _buildServicesCard(services),
          const SizedBox(height: 20),

          _buildOptionTile(
            Icons.person_add_alt_1,
            'Add Worker',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWorkerPage()),
              );
            },
          ),
          _buildOptionTile(
            Icons.edit,
            'Edit Profile',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/agent/edit_profile',
              ).then((_) => _fetchAgentData());
            },
          ),
          _buildOptionTile(
            Icons.settings,
            'Settings',
            onTap: () {
              Navigator.pushNamed(context, '/agent/settings');
            },
          ),
          _buildOptionTile(
            Icons.help_outline,
            'Help & Support',
            onTap: () {
              Navigator.pushNamed(context, '/agent/help');
            },
          ),
          _buildOptionTile(
            Icons.logout,
            'Logout',
            isLogout: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.phone_outlined,
              _agentData?['contact'] ?? 'Not provided',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.location_on_outlined,
              "${_agentData?['address']}, ${_agentData?['city']}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(List<String> services) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Services Offered",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (services.isEmpty)
              const Text(
                "No services listed.",
                style: TextStyle(color: grayBlue),
              ),
            if (services.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: services
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: lightBlue, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: darkBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final color = isLogout ? Colors.red : darkBlue;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: isLogout
          ? null
          : const Icon(Icons.arrow_forward_ios, color: grayBlue, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signup/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
