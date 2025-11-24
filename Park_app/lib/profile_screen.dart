import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'vehicles_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  
  const ProfileScreen({super.key, this.isGuest = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Profile picture options (same as edit profile screen)
  final List<Map<String, dynamic>> _profilePictureOptions = [
    {'name': 'Default', 'icon': Icons.person, 'color': 0xFF1173D4},
    {'name': 'Student', 'icon': Icons.school, 'color': 0xFF4CAF50},
    {'name': 'Professional', 'icon': Icons.business_center, 'color': 0xFF2196F3},
    {'name': 'Creative', 'icon': Icons.palette, 'color': 0xFF9C27B0},
    {'name': 'Tech', 'icon': Icons.computer, 'color': 0xFF607D8B},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': 0xFFFF9800},
    {'name': 'Music', 'icon': Icons.music_note, 'color': 0xFFE91E63},
    {'name': 'Nature', 'icon': Icons.nature, 'color': 0xFF4CAF50},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user is a guest, show login required message
    if (widget.isGuest || FirebaseAuth.instance.currentUser == null) {
      return _buildGuestRestrictionScreen();
    }
    // Prepare display-friendly phone value (support both keys)
    final displayedPhone = _userData?['phone'] ?? _userData?['phoneNumber'];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Profile Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: _getProfilePictureColor().withOpacity(0.1),
                            child: Icon(
                              _getProfilePictureIcon(),
                              size: 32,
                              color: _getProfilePictureColor(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userData?['name'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userData?['email'] ?? 'No Email',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Details
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailTile(
                            icon: Icons.badge_outlined,
                            title: 'Roll Number',
                            value: _userData?['rollNumber'] ?? 'Not provided',
                          ),
                          const Divider(height: 1),
                          _buildDetailTile(
                            icon: Icons.people_outline,
                            title: 'Role',
                            value: _userData?['role'] ?? 'Not specified',
                          ),
                          const Divider(height: 1),
                          _buildDetailTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: _userData?['email'] ?? 'Not provided',
                          ),
                          if (displayedPhone != null && displayedPhone.toString().isNotEmpty) ...[
                            const Divider(height: 1),
                            _buildDetailTile(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              value: displayedPhone ?? 'Not provided',
                            ),
                          ],
                          const Divider(height: 1),
                          _buildDetailTile(
                            icon: Icons.calendar_today_outlined,
                            title: 'Member Since',
                            value: _userData?['createdAt'] != null
                                ? _formatDate(_userData!['createdAt'])
                                : 'Unknown',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToEditProfile(),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF1173D4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToManageVehicles(),
                            icon: const Icon(Icons.directions_car_outlined),
                            label: const Text('Manage Vehicles'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1173D4),
                              side: const BorderSide(color: Color(0xFF1173D4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData),
      ),
    );
    
    // Reload user data if profile was updated
    if (result == true) {
      _loadUserData();
    }
  }

  void _navigateToManageVehicles() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VehiclesScreen(),
      ),
    );
  }

  Color _getProfilePictureColor() {
    final selectedProfilePicture = _userData?['profilePicture'] ?? 'Default';
    final selectedOption = _profilePictureOptions.firstWhere(
      (option) => option['name'] == selectedProfilePicture,
      orElse: () => _profilePictureOptions[0],
    );
    return Color(selectedOption['color']);
  }

  IconData _getProfilePictureIcon() {
    final selectedProfilePicture = _userData?['profilePicture'] ?? 'Default';
    final selectedOption = _profilePictureOptions.firstWhere(
      (option) => option['name'] == selectedProfilePicture,
      orElse: () => _profilePictureOptions[0],
    );
    return selectedOption['icon'];
  }

  Widget _buildGuestRestrictionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 32),
              const Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please login to view your profile. Guest users can only view available parking spots.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
