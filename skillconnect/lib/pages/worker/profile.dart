import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({super.key});

  @override
  WorkerProfilePageState createState() => WorkerProfilePageState();
}

class WorkerProfilePageState extends State<WorkerProfilePage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  Map<String, dynamic>? _workerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
  }

  Future<void> _fetchWorkerData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDocFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final workerDocFuture = FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .get();

      final results = await Future.wait([userDocFuture, workerDocFuture]);
      final userDoc = results[0];
      final workerDoc = results[1];

      if (userDoc.exists && workerDoc.exists && mounted) {
        setState(() {
          _workerData = {
            ...userDoc.data() as Map<String, dynamic>,
            ...workerDoc.data() as Map<String, dynamic>,
          };
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching worker data: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
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
          : _workerData == null
          ? const Center(child: Text("Could not load profile data."))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final name = _workerData?['name'] ?? 'No Name';
    final email = _workerData?['email'] ?? 'No Email';
    final profilePicUrl = _workerData?['profilePicUrl'] ?? '';
    final services = List<String>.from(_workerData?['services'] ?? []);
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

          // 🆕 Past Jobs Option (added before Info Card)
          _buildOptionTile(
            Icons.history,
            'Past Jobs',
            onTap: () {
              Navigator.of(context).pushNamed('/worker/myjobs');
            },
          ),
          const SizedBox(height: 10),

          // Existing Info Card
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildServicesCard(services),
          const SizedBox(height: 20),
          _buildOptionTile(
            Icons.edit,
            'Edit Profile',
            onTap: () {
              Navigator.of(context).pushNamed('/worker/editprofile');
            },
          ),
          _buildOptionTile(
            Icons.help_outline,
            'Help & Support',
            onTap: () {
              Navigator.of(context).pushNamed('/worker/help');
            },
          ),
          _buildOptionTile(
            Icons.logout,
            'Logout',
            isLogout: true,
            onTap: _handleLogout,
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
        child: _buildInfoRow(
          Icons.phone_outlined,
          _workerData?['contact'] ?? 'Not provided',
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
              "My Skills",
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
}
