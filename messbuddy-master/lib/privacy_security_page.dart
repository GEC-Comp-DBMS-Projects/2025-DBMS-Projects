import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'change_password_page.dart'; // Import the change password page
import 'two_factor_auth_page.dart'; // Import the two-factor auth page

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Toggle states for privacy options
  bool _locationSharing = true;
  bool _dataCollection = true;
  bool _profileVisibility = false;
  
  // Matching the color palette from the other pages
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _tertiaryAccent = const Color(0xFFFFD60A); // Gold accent
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _dangerColor = const Color(0xFFFF4D4D); // Red for destructive actions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'privacy & security',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _accentColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'your privacy matters',
                                style: GoogleFonts.poppins(
                                  color: _textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'control how your data is used and protected 🛡️',
                                style: GoogleFonts.poppins(
                                  color: _textSecondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Privacy settings section
                    _buildSectionHeader('privacy settings', Icons.privacy_tip_outlined, _primaryColor),
                    const SizedBox(height: 15),
                    _buildPrivacyContainer(),
                    
                    const SizedBox(height: 25),
                    
                    // Account security section
                    _buildSectionHeader('account security', Icons.security_outlined, _secondaryAccent),
                    const SizedBox(height: 15),
                    _buildSecurityContainer(),
                    
                    const SizedBox(height: 25),
                    
                    // Data storage section
                    _buildSectionHeader('data & storage', Icons.storage_outlined, _accentColor),
                    const SizedBox(height: 15),
                    _buildDataStorageContainer(),
                    
                    const SizedBox(height: 25),
                    
                    // Privacy policy section
                    _buildPrivacyPolicySection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
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
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyContainer() {
    return Container(
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
      child: Column(
        children: [
          _buildToggleOption(
            title: 'location sharing',
            subtitle: 'allow app to access your location',
            value: _locationSharing,
            color: _accentColor,
            onChanged: (value) {
              setState(() {
                _locationSharing = value;
              });
            },
          ),
          _buildDivider(),
          _buildToggleOption(
            title: 'data collection',
            subtitle: 'allow app to collect usage data',
            value: _dataCollection,
            color: _primaryColor,
            onChanged: (value) {
              setState(() {
                _dataCollection = value;
              });
            },
          ),
          _buildDivider(),
          _buildToggleOption(
            title: 'profile visibility',
            subtitle: 'make your profile visible to other users',
            value: _profileVisibility,
            color: _secondaryAccent,
            onChanged: (value) {
              setState(() {
                _profileVisibility = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityContainer() {
    return Container(
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
      child: Column(
        children: [
          _buildSecurityOption(
            icon: Icons.lock_outline_rounded,
            title: 'change password',
            color: _secondaryAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          _buildDivider(),
          _buildSecurityOption(
            icon: Icons.phonelink_lock_outlined,
            title: 'two-factor authentication',
            color: _accentColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TwoFactorAuthPage()),
              );
            },
          ),
          _buildDivider(),
          _buildSecurityOption(
            icon: Icons.devices_outlined,
            title: 'manage devices',
            color: _primaryColor,
            onTap: () {
              _showFeatureSnackbar('manage devices');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataStorageContainer() {
    return Container(
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
      child: Column(
        children: [
          _buildSecurityOption(
            icon: Icons.delete_outline_rounded,
            title: 'clear cache',
            color: _tertiaryAccent,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'cache cleared successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _cardBackgroundAltColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'ok',
                    textColor: _accentColor,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSecurityOption(
            icon: Icons.download_outlined,
            title: 'download personal data',
            color: _accentColor,
            onTap: () {
              _showFeatureSnackbar('download personal data');
            },
          ),
          _buildDivider(),
          _buildSecurityOption(
            icon: Icons.delete_forever_outlined,
            title: 'delete account',
            color: _dangerColor,
            isDestructive: true,
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        border: Border.all(
          color: _accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _accentColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'privacy policy',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'read our privacy policy to understand how we collect, use, and protect your personal information.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: _textSecondaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: TextButton.icon(
              onPressed: () {
                _showFeatureSnackbar('privacy policy');
              },
              icon: Icon(
                Icons.open_in_new_rounded,
                color: _accentColor,
                size: 18,
              ),
              label: Text(
                'view policy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              value ? Icons.check_rounded : Icons.close_rounded,
              color: value ? color : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
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
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? _dangerColor : _textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardBackgroundAltColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDestructive ? _dangerColor.withOpacity(0.7) : _textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'coming soon: $feature feature',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _cardBackgroundAltColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'delete account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: _textColor,
            fontSize: 18,
          ),
        ),
        content: Text(
          'are you sure you want to delete your account? this action cannot be undone and all your data will be permanently lost.',
          style: GoogleFonts.poppins(
            color: _textSecondaryColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: _textSecondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeatureSnackbar('account deletion');
            },
            child: Text(
              'delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _dangerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}