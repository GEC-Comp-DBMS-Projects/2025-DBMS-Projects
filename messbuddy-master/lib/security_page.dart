import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'change_password_page.dart'; // Import the change password page
import 'two_factor_auth_page.dart'; // Import the two-factor auth page
import 'privacy_security_page.dart'; // Import the privacy security page

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  // Refined color palette matching the home page
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Security',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'account security',
              style: GoogleFonts.poppins(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: _cardBackgroundColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSecurityButton(
                    title: 'Change Password',
                    icon: Icons.lock_outline_rounded,
                    color: _primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityButton(
                    title: 'Two Factor Authentication',
                    icon: Icons.security_rounded,
                    color: _secondaryAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TwoFactorAuthPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityButton(
                    title: 'Privacy Settings',
                    icon: Icons.privacy_tip_rounded,
                    color: _accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: _cardBackgroundAltColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: _textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}