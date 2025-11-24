import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'help_support_page.dart';
import 'privacy_security_page.dart';
import 'about_page.dart'; // Import the about page
import 'package:awesome_notifications/awesome_notifications.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  
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
  
  // Settings menu items with icons and colors
  late List<Map<String, dynamic>> _settingsItems;

  @override
  void initState() {
    super.initState();
    
    // Initialize settings items with notification badge status
    _initializeSettingsItems();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Check notification status when the page loads
    _checkNotificationStatus();
  }
  
  void _initializeSettingsItems() {
    _settingsItems = [
      {
        'icon': Icons.security_outlined,
        'title': 'security',
        'color': Color(0xFFFF2D55), // Primary color
        'route': SecurityPage(),
        'showBadge': false,
      },
      {
        'icon': Icons.notifications_none_outlined,
        'title': 'notifications',
        'color': Color(0xFF04E9CC), // Accent color
        'route': NotificationSettingsPage(),
        'showBadge': false, // Will be updated in _checkNotificationStatus
      },
      {
        'icon': Icons.headset_mic_outlined,
        'title': 'help and support',
        'color': Color(0xFF7F5AF7), // Secondary accent
        'route': HelpSupportPage(),
        'showBadge': false,
      },
      {
        'icon': Icons.lock_outline,
        'title': 'privacy and security',
        'color': Color(0xFFFFD60A), // Tertiary accent
        'route': PrivacySecurityPage(),
        'showBadge': false,
      },
      {
        'icon': Icons.language_rounded,
        'title': 'language',
        'color': Color(0xFFFF2D55), // Primary color
        'route': null, // No page yet
        'showBadge': false,
      },
      {
        'icon': Icons.brightness_6_outlined,
        'title': 'appearance',
        'color': Color(0xFF04E9CC), // Accent color
        'route': null, // No page yet
        'showBadge': false,
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'about messbuddy',
        'color': Color(0xFF7F5AF7), // Secondary accent
        'route': AboutPage(), // Link to the about page
        'showBadge': false,
      },
    ];
  }
  
  // Check if notifications are active and update badge status
  Future<void> _checkNotificationStatus() async {
    try {
      final List<NotificationModel> activeSchedules = await AwesomeNotifications().listScheduledNotifications();
      
      setState(() {
        // Update notification badge status if there are active notifications
        // This will put a badge on the notifications menu item
        _settingsItems[1]['showBadge'] = activeSchedules.isNotEmpty;
      });
    } catch (e) {
      print("Error checking notification status: $e");
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'settings',
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
                                'customize your app',
                                style: GoogleFonts.poppins(
                                  color: _textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'adjust settings to fit your preferences ✨',
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
                    const SizedBox(height: 25),
                    
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 25),
                    
                    // Settings items
                    ..._settingsItems.map((item) => _buildSettingsItem(
                      context: context,
                      icon: item['icon'],
                      title: item['title'],
                      color: item['color'],
                      showBadge: item['showBadge'],
                      onTap: () {
                        final route = item['route'];
                        if (route != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => route),
                          ).then((_) {
                            // Refresh the notification status when returning from settings pages
                            _checkNotificationStatus();
                          });
                        } else {
                          // Handle null routes (features not yet implemented)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'coming soon: ${item['title']} settings',
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
                      },
                    )),
                    
                    const SizedBox(height: 25),
                    
                    // Version info
                    Center(
                      child: Text(
                        'messbuddy v1.0.0',
                        style: GoogleFonts.poppins(
                          color: _textSecondaryColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _cardBackgroundAltColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          color: _textColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'search settings...',
          hintStyle: GoogleFonts.poppins(
            color: _textSecondaryColor.withOpacity(0.5),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _textSecondaryColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) {
          // If search functionality is implemented, filter settings here
        },
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: _cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon with custom container
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 22,
                          ),
                        ),
                        if (showBadge)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _cardBackgroundColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                    const Spacer(),
                    
                    // Arrow icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cardBackgroundAltColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: _textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}