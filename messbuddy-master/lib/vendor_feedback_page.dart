import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorFeedbackPage extends StatefulWidget {
  const VendorFeedbackPage({super.key});

  @override
  State<VendorFeedbackPage> createState() => _VendorFeedbackPageState();
}

class _VendorFeedbackPageState extends State<VendorFeedbackPage> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  late AnimationController _pulseController;

  // Theme colors - matching HomeScreen
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

  // Emojis for Gen Z vibe
  final String _sparkleEmoji = "✨";
  final String _starEmoji = "⭐";
  final String _speakingEmoji = "🗣️";

  @override
  void initState() {
    super.initState();
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the date for display and document ID
    final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final displayDate = DateFormat('MMMM d, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'feedback vibes',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _cardBackgroundAltColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.info_outline_rounded,
                color: _accentColor,
              ),
              onPressed: () {
                // Show info about feedback metrics
                _showInfoDialog();
              },
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle background gradient
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
          
          // Background design elements - minimal glow spots
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
            child: Column(
              children: [
                // Date selector
                _buildDateSelector(displayDate),

                // Feedback summary card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildFeedbackSummaryCard(dateStr),
                ),

                // List of feedback
                Expanded(
                  child: _buildFeedbackList(dateStr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String displayDate) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: _primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                displayDate.toLowerCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: _primaryColor,
                        onPrimary: Colors.white,
                        surface: _cardBackgroundColor,
                        onSurface: _textColor,
                      ),
                      dialogBackgroundColor: _cardBackgroundAltColor,
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'change',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSummaryCard(String dateStr) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_feedbacks')
          .doc(dateStr)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: _accentColor),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _textSecondaryColor.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'feedback summary ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    Text(_sparkleEmoji),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'no feedback yet for ${DateFormat('MMM d').format(_selectedDate).toLowerCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardBackgroundAltColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: _secondaryAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'check back later or try another date',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate statistics
        final data = snapshot.data!.data() as Map<String, dynamic>;
        int totalFeedbacks = 0;
        double totalRating = 0;
        int resolved = 0;
        int unresolved = 0;

        data.forEach((userId, feedbackData) {
          if (feedbackData is Map<String, dynamic>) {
            totalFeedbacks++;
            totalRating += (feedbackData['rating'] ?? 0).toDouble();
            if (feedbackData['resolved'] == true) {
              resolved++;
            } else {
              unresolved++;
            }
          }
        });

        final avgRating = totalFeedbacks > 0 
            ? (totalRating / totalFeedbacks).toStringAsFixed(1) 
            : '0';

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: _cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'feedback summary ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  Text(_sparkleEmoji),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('total', totalFeedbacks.toString(), Icons.message_rounded, _accentColor),
                  _buildStatItem('avg rating', avgRating, Icons.star_rounded, _tertiaryAccent, isRating: true),
                  _buildStatItem('resolved', '$resolved/$totalFeedbacks', Icons.check_circle_rounded, _successColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, {bool isRating = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackList(String dateStr) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_feedbacks')
          .doc(dateStr)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: _accentColor),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 70,
                  color: _textSecondaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'no feedback yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'feedback will appear here when users submit it',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _textSecondaryColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final feedbackEntries = <MapEntry<String, dynamic>>[];
        
        data.forEach((userId, feedback) {
          if (feedback is Map<String, dynamic>) {
            feedbackEntries.add(MapEntry(userId, feedback));
          }
        });

        // Sort by timestamp (newest first) if available
        feedbackEntries.sort((a, b) {
          final aTime = a.value['timestamp'] as Timestamp?;
          final bTime = b.value['timestamp'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: feedbackEntries.length,
          itemBuilder: (context, index) {
            final entry = feedbackEntries[index];
            final userId = entry.key;
            final feedback = entry.value as Map<String, dynamic>;
            
            final rating = (feedback['rating'] ?? 0).toDouble();
            final message = feedback['message'] as String? ?? '';
            // Always show Anonymous instead of attempting to use userName
            final userName = 'anonymous';
            final isResolved = feedback['resolved'] as bool? ?? false;
            final timestamp = feedback['timestamp'] as Timestamp?;
            final timeString = timestamp != null 
                ? DateFormat('hh:mm a').format(timestamp.toDate()).toLowerCase()
                : 'unknown time';

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: _cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isResolved 
                    ? _successColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info and timestamp
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _cardBackgroundAltColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '👤',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _textColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _cardBackgroundAltColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: _textSecondaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeString,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Feedback content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating with stars
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _cardBackgroundAltColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < rating 
                                    ? Icons.star_rounded 
                                    : Icons.star_outline_rounded,
                                  color: _tertiaryAccent,
                                  size: 18,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                rating.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _tertiaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Feedback message
                        if (message.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _primaryColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _speakingEmoji,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        const SizedBox(height: 16),
                        
                        // Status and action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isResolved
                                  ? _successColor.withOpacity(0.1)
                                  : _secondaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isResolved
                                    ? _successColor.withOpacity(0.3)
                                    : _secondaryAccent.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isResolved
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_actions_rounded,
                                    color: isResolved ? _successColor : _secondaryAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isResolved ? 'resolved' : 'pending',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isResolved ? _successColor : _secondaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isResolved)
                              GestureDetector(
                                onTap: () => _markAsResolved(dateStr, userId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_accentColor, _successColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _accentColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.done_all_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'resolve',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _markAsResolved(String dateStr, String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('daily_feedbacks')
          .doc(dateStr)
          .update({
        '$userId.resolved': true,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: _successColor),
              const SizedBox(width: 10),
              Text(
                'feedback marked as resolved',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: _cardBackgroundAltColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: _accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'about feedback metrics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                Icons.message_rounded,
                'total feedback',
                'total number of feedbacks received on this date',
                _accentColor,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.star_rounded,
                'avg rating',
                'average of all ratings (1-5 stars)',
                _tertiaryAccent,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.check_circle_rounded,
                'resolved',
                'number of resolved issues out of total',
                _successColor,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: _primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'got it!',
                  style: GoogleFonts.poppins(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}