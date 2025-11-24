import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/screens/home_page.dart';
import 'package:app/screens/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final String role;

  const ProfilePage({super.key, required this.uid, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _orgIdController = TextEditingController();
  String? _email;
  String? _role;
  String? _joinedDate;
  String? _phone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('crowdr')
          .doc('users')
          .collection(widget.uid)
          .doc("profile")
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['username'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        _role = data['role'] ?? widget.role;
        _orgIdController.text = data['organizationId'] ?? '';

        final ts = data['createdAt'];
        if (ts is Timestamp) {
          _joinedDate = ts.toDate().toString().split(' ')[0];
        }
      } else {
        debugPrint("❌ Document not found for UID: ${widget.uid}");
      }
    } catch (e) {
      debugPrint("🔥 Error fetching user data: $e");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('crowdr')
          .doc('users')
          .collection(widget.uid)
          .doc("profile")
      
          .update({
        'username': _nameController.text.trim(),
        if (widget.role == 'organizer')
          'organizationId': _orgIdController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ✅ Now logout redirects to SignInPage
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(), // 👈 Redirects to your sign-in screen
        ),
        (route) => false,
      );
    }
  }

  Widget _infoTile(String label, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.shade700, width: 1),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: Colors.deepPurpleAccent, size: 20),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 3),
                Text(value.isNotEmpty ? value : 'Not available',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(uid: widget.uid, role: widget.role),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 20),

                  _infoTile('Name', _nameController.text, icon: Icons.person),
                  _infoTile('Email', _email ?? '', icon: Icons.email),
                  _infoTile('Phone', _phone ?? '', icon: Icons.phone),
                  _infoTile('Role', _role ?? widget.role, icon: Icons.badge),
                  if (widget.role == 'organizer')
                    _infoTile('Organization ID', _orgIdController.text,
                        icon: Icons.business),
                  if (_joinedDate != null)
                    _infoTile('Joined On', _joinedDate!,
                        icon: Icons.calendar_today),

                  const SizedBox(height: 30),

                  // ✅ Logout button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
