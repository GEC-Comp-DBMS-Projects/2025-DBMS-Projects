import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillconnect/pages/customer/editprofile.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({super.key});
  @override
  CustomerProfileState createState() => CustomerProfileState();
}

class CustomerProfileState extends State<CustomerProfile> {
  String? _userName;
  String? _userEmail;
  String? _userProfilePicUrl;
  bool _isLoading = true;

  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color mediumBlue = Color(0xFF545E75);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color paleBlue = Color(0xFFA7CCED);
  static const Color grayBlue = Color(0xFF82A0BC);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user logged in");
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _userName = userDoc.get('name');
          _userEmail = userDoc.get('email');
          _userProfilePicUrl = userDoc.get('profilePicUrl');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) {
      // This block runs when you return from EditProfilePage
      // Refresh data in case changes were made
      setState(() {
        _isLoading = true;
      });
      _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lightBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
                    _buildOptionTile(
                      Icons.edit_outlined,
                      'Edit Profile',
                      onTap: _navigateToEditProfile,
                    ),
                    _buildOptionTile(
                      Icons.settings_outlined,
                      'Settings',
                      onTap: () {
                        Navigator.pushNamed(context, '/customer/settings');
                      },
                    ),
                    _buildOptionTile(
                      Icons.help_outline,
                      'Help & Support',
                      onTap: () {
                        Navigator.pushNamed(context, '/customer/help');
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
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    String initial = _userName != null && _userName!.isNotEmpty
        ? _userName![0].toUpperCase()
        : 'C';

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: paleBlue,
          backgroundImage:
              _userProfilePicUrl != null && _userProfilePicUrl!.isNotEmpty
              ? NetworkImage(_userProfilePicUrl!)
              : null,
          child: (_userProfilePicUrl == null || _userProfilePicUrl!.isEmpty)
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _userName ?? 'Customer Name',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        Text(
          _userEmail ?? 'customer@email.com',
          style: const TextStyle(fontSize: 14, color: grayBlue),
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
    final color = isLogout ? Colors.redAccent : darkBlue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, color: color)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: grayBlue,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
