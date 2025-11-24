import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecentActivitiesPage extends StatefulWidget {
  const RecentActivitiesPage({super.key});

  @override
  State<RecentActivitiesPage> createState() => _RecentActivitiesPageState();
}

class _RecentActivitiesPageState extends State<RecentActivitiesPage> {
  // Matching the color palette from the HomePage
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

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _activityStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _activityStream = FirebaseFirestore.instance.collection('recent_activity').doc(user.uid).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'recent activities',
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
          if (_activityStream != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _activityStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: _accentColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'loading activities...',
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildEmptyState();
                }
                final data = snapshot.data!.data();
                final activities = (data?['activities'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
                // Sort by timestamp descending
                activities.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
                return _buildActivitiesList(activities);
              },
            )
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: _textSecondaryColor,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'no recent activities',
            style: GoogleFonts.poppins(
              color: _textSecondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'your activities will appear here',
            style: GoogleFonts.poppins(
              color: _textSecondaryColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<Map<String, dynamic>> activities) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final activityStr = activity['activity'] as String;
        final timestamp = activity['timestamp'] as Timestamp;
        final timeAgo = _getTimeAgo(timestamp.toDate());
        final icon = _getActivityIcon(activityStr);
        final color = _getActivityColor(activityStr);
        return Column(
          children: [
            _buildActivityItem(activityStr, timeAgo, icon, color),
            if (index < activities.length - 1)
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.05),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: _textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: _textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  IconData _getActivityIcon(String activity) {
    if (activity.contains('booked')) return Icons.restaurant;
    if (activity.contains('Feedback')) return Icons.star;
    return Icons.info;
  }

  Color _getActivityColor(String activity) {
    if (activity.contains('booked')) return _primaryColor;
    if (activity.contains('Feedback')) return _accentColor;
    return _secondaryAccent;
  }
}