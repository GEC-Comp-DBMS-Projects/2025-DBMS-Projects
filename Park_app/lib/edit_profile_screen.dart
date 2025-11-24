import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfileScreen({
    super.key,
    this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _roleController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'Student';
  String? _selectedProfilePicture;
  bool _isLoading = false;
  
  final List<String> _roles = [
    'Student',
    'Faculty',
    'Staff',
    'Visitor',
  ];

  // Generic profile picture options
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
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.userData != null) {
      _nameController.text = widget.userData!['name'] ?? '';
      _rollNumberController.text = widget.userData!['rollNumber'] ?? '';
      _roleController.text = widget.userData!['role'] ?? 'Student';
      // Support either 'phone' or legacy 'phoneNumber' keys
      _phoneController.text = widget.userData!['phone'] ?? widget.userData!['phoneNumber'] ?? '';
      _selectedProfilePicture = widget.userData!['profilePicture'] ?? 'Default';
      
      // Handle case sensitivity for role selection
      final userRole = widget.userData!['role'] ?? 'Student';
      _selectedRole = _roles.firstWhere(
        (role) => role.toLowerCase() == userRole.toLowerCase(),
        orElse: () => 'Student',
      );
    } else {
      _selectedProfilePicture = 'Default';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      
      // Get current user's role from Firestore to prevent role changes
      final currentUserDoc = await _firestore.collection('users').doc(user.uid).get();
      String roleToSave = _selectedRole;
      
      // If user is already an admin/staff, keep their original role
      if (currentUserDoc.exists) {
        final currentRole = currentUserDoc.data()?['role'] as String?;
        if (currentRole?.toLowerCase() == 'admin' || currentRole?.toLowerCase() == 'staff') {
          roleToSave = currentRole!; // Keep their admin/staff status
        } else if (_selectedRole.toLowerCase() == 'admin' || _selectedRole.toLowerCase() == 'staff') {
          roleToSave = 'Student'; // Prevent users from setting themselves as admin
        }
      }
      
      final userData = {
        'name': _nameController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'role': roleToSave,
        'profilePicture': _selectedProfilePicture ?? 'Default',
        'email': user.email,
        // Write phone in both keys for compatibility with older documents
        'phone': _phoneController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'updatedAt': now.toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : const Color(0xFF1173D4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showProfilePicturePicker,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: _getProfilePictureColor().withOpacity(0.1),
                          child: Icon(
                            _getProfilePictureIcon(),
                            size: 36,
                            color: _getProfilePictureColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Profile Picture',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to change',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form Fields
                _buildFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildFormField(
                  controller: _rollNumberController,
                  label: 'Roll Number / ID',
                  hint: 'Enter your roll number or ID',
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email field (read-only)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          _auth.currentUser?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'Email cannot be changed here. Contact support if needed.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildFormField(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      // Basic phone validation
                      final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Role Display (Read-only)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Role',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedRole,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'To change your role, please contact support.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173D4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Profile'),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF1173D4)),
                    ),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF1173D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
              ),
              validator: validator,
              onChanged: (value) {
                setState(() {}); // Update avatar initial
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProfilePicturePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Profile Picture'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _profilePictureOptions.length,
            itemBuilder: (context, index) {
              final option = _profilePictureOptions[index];
              final isSelected = _selectedProfilePicture == option['name'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfilePicture = option['name'];
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(option['color']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(option['color']) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    option['icon'],
                    color: Color(option['color']),
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getProfilePictureColor() {
    final selectedOption = _profilePictureOptions.firstWhere(
      (option) => option['name'] == _selectedProfilePicture,
      orElse: () => _profilePictureOptions[0],
    );
    return Color(selectedOption['color']);
  }

  IconData _getProfilePictureIcon() {
    final selectedOption = _profilePictureOptions.firstWhere(
      (option) => option['name'] == _selectedProfilePicture,
      orElse: () => _profilePictureOptions[0],
    );
    return selectedOption['icon'];
  }
}
