import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings.dart';
import "login.dart";

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color palette to match the app theme
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _tertiaryAccent = const Color(0xFFFFD60A); // Gold accent
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _successColor = const Color(0xFF33FF99); // Mint green
  final Color _dangerColor = const Color(0xFFFF4D4D); // Red for logout/delete

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  late AnimationController _pulseController;

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _rollNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _hostelController;
  late TextEditingController _roomNumberController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _rollNumberController = TextEditingController();
    _phoneController = TextEditingController();
    _hostelController = TextEditingController();
    _roomNumberController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    _user = _auth.currentUser;

    if (_user != null) {
      // Fetch user data from Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (docSnapshot.exists) {
        _userData = docSnapshot.data();
        // Set controller values from fetched data
        _nameController.text = _userData?['name'] ?? 'no name';
        _rollNumberController.text = _userData?['roll_no'] ?? '';
        _phoneController.text = _userData?['phoneNumber'] ?? '';
        _hostelController.text = _userData?['hostel_no'] ?? '';
        _roomNumberController.text = _userData?['room_no'] ?? '';
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _rollNumberController.dispose();
    _phoneController.dispose();
    _hostelController.dispose();
    _roomNumberController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': _nameController.text.trim(),
        'roll_no': _rollNumberController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'hostel_no': _hostelController.text.trim(),
        'room_no': _roomNumberController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'profile updated successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'ok',
            textColor: _accentColor,
            onPressed: () {},
          ),
        ),
      );

      // Exit editing mode and reload data to reflect changes
      setState(() {
        _isEditing = false;
      });
      _loadUserData(); // Reload the data from Firestore

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'failed to update profile: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset text fields to original values by reloading data
      _loadUserData();
    });
  }

  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'logout',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: _textSecondaryColor,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _textSecondaryColor,
            ),
            child: Text(
              'cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'profile & settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 18,
            color: _textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_rounded, 
              color: _isEditing ? _textSecondaryColor : _accentColor,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _cancelEdit(); // If in edit mode, the close button cancels
                } else {
                  _isEditing = true; // If not, it enables edit mode
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  _backgroundColor.withOpacity(0.9),
                  _backgroundColor,
                ],
              ),
            ),
          ),
          
          // Background accent circles
          Positioned(
            top: -50,
            right: -30,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_primaryColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_accentColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          
          // Main content
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 3,
                  ),
                )
              : _user == null 
                  ? Center(
                      child: Text(
                        "please log in first",
                        style: GoogleFonts.poppins(
                          color: _textColor,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 25),
                          _buildProfileDetails(),
                          const SizedBox(height: 25),
                          _buildSettingsTile(context),
                          const SizedBox(height: 40),
                          _buildLogoutButton(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String firstName = _nameController.text.split(' ').first;
    final String fullName = _nameController.text;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with animated border
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              _primaryColor,
                              _accentColor,
                              _secondaryAccent,
                              _primaryColor,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                            startAngle: _pulseController.value * 3.14 * 2,
                            endAngle: (1 + _pulseController.value) * 3.14 * 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _cardBackgroundColor,
                        ),
                        child: Center(
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(
                              color: _textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(width: 20),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isEditing 
                      ? _buildEditableTextField(
                          _nameController, 
                          "full name", 
                          isMainTitle: true
                        )
                      : Text(
                          fullName.toLowerCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email?.toLowerCase() ?? 'no email',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textSecondaryColor,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _secondaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _secondaryAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'student',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _secondaryAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: _primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'profile details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          // Student details section
          _buildInfoField('roll number', _rollNumberController),
          _buildDivider(),
          _buildInfoField('phone number', _phoneController),
          _buildDivider(),
          
          // Room details section
          Row(
            children: [
              Expanded(child: _buildInfoField('hostel', _hostelController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoField('room number', _roomNumberController)),
            ],
          ),
          
          // Save/Cancel buttons when editing
          if (_isEditing) ...[
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'save changes',
                    _isSaving ? null : _saveChanges,
                    [_accentColor, _accentColor.withGreen(180)],
                    isLoading: _isSaving,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    'cancel',
                    _cancelEdit,
                    [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.4)],
                    textColor: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _textSecondaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          _isEditing
            ? _buildTextField(controller)
            : Text(
                controller.text.isEmpty ? 'not set' : controller.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: controller.text.isEmpty ? _textSecondaryColor.withOpacity(0.5) : _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackgroundAltColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: _textColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'enter value...',
          hintStyle: GoogleFonts.poppins(
            color: _textSecondaryColor.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTextField(TextEditingController controller, String label, {bool isMainTitle = false}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: isMainTitle ? 22 : 16,
        fontWeight: isMainTitle ? FontWeight.bold : FontWeight.w500,
        color: _textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: _textSecondaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        isDense: true,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _accentColor.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _accentColor),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text, 
    VoidCallback? onPressed, 
    List<Color> gradientColors, {
    bool isLoading = false,
    Color? textColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(
                  strokeWidth: 2.5, 
                  color: _textColor,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? _textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _secondaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: _secondaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              'app settings',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_dangerColor, _dangerColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _dangerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _confirmLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: _textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'logout',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}