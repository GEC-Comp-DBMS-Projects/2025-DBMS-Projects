import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  UserTypeSelectionScreenState createState() => UserTypeSelectionScreenState();
}

class UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? _selectedUserType;

  // SkillConnect Color Scheme
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color mediumBlue = Color(0xFF545E75);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color paleBlue = Color(0xFFA7CCED);
  static const Color grayBlue = Color(0xFF82A0BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Join SkillConnect', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- MODIFIED: Replaced Icon with Image Logo ---
            Container(
              width: 80,
              height: 80,
              clipBehavior:
                  Clip.antiAlias, // Clips the image to the border radius
              decoration: BoxDecoration(
                color: lightBlue, // Background color if image is transparent
                borderRadius: BorderRadius.circular(20),
              ),
              child: Transform.scale(
                scale: 1.9, // Scale the image to fit bett
                child: Image.asset(
                  'assets/images/skillconnect_logo.jpg',
                  fit: BoxFit.cover,
                  // Fallback in case the image fails to load
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.handyman, size: 50, color: Colors.white);
                  },
                ),
              ),
            ),
            // --- END MODIFICATION ---
            SizedBox(height: 20),

            Text(
              'Welcome to SkillConnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            Text(
              'Choose how you\'d like to join our community',
              style: TextStyle(color: paleBlue, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),

            // Customer Option
            _buildUserTypeCard(
              type: 'Customer',
              title: 'I need services',
              subtitle: 'Find skilled workers for your tasks',
              icon: Icons.person_outline,
              isSelected: _selectedUserType == 'Customer',
              onTap: () {
                setState(() {
                  _selectedUserType = 'Customer';
                });
              },
            ),

            SizedBox(height: 20),

            // Worker Option
            _buildUserTypeCard(
              type: 'Worker',
              title: 'I provide services',
              subtitle: 'Offer your skills and earn money',
              icon: Icons.build_outlined,
              isSelected: _selectedUserType == 'Worker',
              onTap: () {
                setState(() {
                  _selectedUserType = 'Worker';
                });
              },
            ),

            SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedUserType != null ? _continueToSignup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedUserType != null
                      ? lightBlue
                      : grayBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: paleBlue, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/signup/login');
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: lightBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? lightBlue.withAlpha(51) // 0.2 opacity
              : mediumBlue.withAlpha(76), // 0.3 opacity
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? lightBlue : grayBlue,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? lightBlue : grayBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: paleBlue, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: lightBlue, size: 24),
          ],
        ),
      ),
    );
  }

  void _continueToSignup() {
    if (_selectedUserType == 'Customer') {
      Navigator.pushNamed(context, '/signup/csignup');
    } else if (_selectedUserType == 'Worker') {
      Navigator.pushNamed(context, '/signup/wsignup');
    }
  }
}
