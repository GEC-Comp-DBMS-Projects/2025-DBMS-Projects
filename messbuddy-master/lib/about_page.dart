import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Matching the color palette from the other pages
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _tertiaryAccent = const Color(0xFFFFD60A); // Gold accent
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
          'about messbuddy',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
              padding: const EdgeInsets.all(20),
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
                              '📱 messbuddy',
                              style: GoogleFonts.poppins(
                                color: _textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'simplifying hostel mess management',
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

                  // About section
                  _buildSectionCard(
                    title: 'about the app',
                    content: 'MessBuddy is a smart and intuitive mobile application built to simplify and modernize hostel mess management. '
                        'The app allows students to view daily and weekly menus, mark or check their mess attendance, give feedback on meals, '
                        'and receive instant updates about any changes or special announcements — all from their phones.\n\n'
                        'For mess administrators, it provides a smoother way to manage attendance records, analyze student participation, and communicate efficiently.\n\n'
                        'In short, MessBuddy bridges the gap between students and mess administration, bringing transparency, convenience, '
                        'and digital efficiency to an essential daily routine.',
                    emoji: '🚀',
                  ),
                  const SizedBox(height: 20),

                  // Why created section
                  _buildSectionCard(
                    title: 'why it was created',
                    content: 'The idea for MessBuddy emerged from the common issues faced in hostels — students missing important meal updates, '
                        'miscommunication between staff and residents, and the lack of a proper feedback system.\n\n'
                        'The traditional paper-based or manual mess management systems are time-consuming and prone to errors. '
                        'Recognizing this, MessBuddy was created to digitize the entire process, making it faster, more reliable, and user-friendly.\n\n'
                        'The goal is to provide a centralized digital platform that enhances coordination between hostel mess staff and students, '
                        'improves transparency, and ensures a smoother dining experience for everyone.',
                    emoji: '💡',
                  ),
                  const SizedBox(height: 20),

                  // Developed by section
                  _buildSectionCard(
                    title: 'developed by',
                    content: 'Atharv Govekar\nChinmay Gadgil\nAudumber Shirodkar\n\n'
                        'Students of Third Year Computer Engineering,\n'
                        'Goa College of Engineering, Farmagudi.',
                    emoji: '👨‍💻',
                  ),
                  const SizedBox(height: 20),

                  // Version section
                  _buildSectionCard(
                    title: 'version information',
                    content: 'Version: 1.0.0\nRelease Date: October 2025',
                    emoji: '⚙️',
                  ),
                  const SizedBox(height: 20),

                  // Contact section
                  _buildSectionCard(
                    title: 'contact & support',
                    content: 'For queries or support, contact us at:\n'
                        '• messbuddy.support@gmail.com\n'
                        '• help.messbuddy.team@gmail.com',
                    emoji: '📬',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required String emoji,
  }) {
    return Container(
      width: double.infinity,
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
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: _textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}