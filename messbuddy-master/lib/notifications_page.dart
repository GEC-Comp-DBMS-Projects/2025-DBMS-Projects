import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> with SingleTickerProviderStateMixin {
  // Define toggle states
  bool _bookingReminder = true;
  bool _paymentAlerts = true;
  bool _menuUpdates = false;
  bool _specialOffers = true;
  bool _messUpdates = true;
  bool _feedbackRequests = false;
  
  // Animation controller
  late AnimationController _pulseController;
  
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
  
  // Notification categories with icons and colors
  final List<Map<String, dynamic>> _notificationCategories = [
    {
      'title': 'meal reminders',
      'subtitle': 'remind me to book meals in advance',
      'icon': Icons.restaurant_menu_rounded,
      'color': Color(0xFFFF2D55), // Primary color
      'toggleFunction': '_toggleMealNotifications',
    },
    {
      'title': 'payment alerts',
      'subtitle': 'transaction confirmations and receipts',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF04E9CC), // Accent color
      'toggleFunction': '_togglePaymentNotifications',
    },
    {
      'title': 'menu updates',
      'subtitle': 'get notified when the menu changes',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF7F5AF7), // Secondary accent
      'toggleFunction': '_toggleMenuNotifications',
    },
    {
      'title': 'special offers',
      'subtitle': 'promotional offers and discounts',
      'icon': Icons.local_offer_rounded,
      'color': Color(0xFFFFD60A), // Tertiary accent
      'toggleFunction': '_toggleOfferNotifications',
    },
    {
      'title': 'mess updates',
      'subtitle': 'important announcements about the mess',
      'icon': Icons.announcement_rounded,
      'color': Color(0xFFFF2D55), // Primary color
      'toggleFunction': '_toggleMessUpdatesNotifications',
    },
    {
      'title': 'feedback requests',
      'subtitle': 'requests to rate your meal experience',
      'icon': Icons.rate_review_rounded,
      'color': Color(0xFF04E9CC), // Accent color
      'toggleFunction': '_toggleFeedbackNotifications',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Check if notifications are enabled on start
    _checkNotificationStatus();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  // Check if notifications are already scheduled
  Future<void> _checkNotificationStatus() async {
    try {
      final List<NotificationModel> activeSchedules = await AwesomeNotifications().listScheduledNotifications();
      
      setState(() {
        // Check if meal notifications (IDs 1-3) are scheduled
        _bookingReminder = activeSchedules.any((notification) => 
          notification.content!.id == 1 || 
          notification.content!.id == 2 || 
          notification.content!.id == 3);
          
        // You can add similar checks for other notification types
        // For now, we'll leave the others as they are
      });
    } catch (e) {
      print("Error checking notification status: $e");
    }
  }
  
  // Helper function to get toggle value based on index
  bool _getToggleValue(int index) {
    switch (index) {
      case 0: return _bookingReminder;
      case 1: return _paymentAlerts;
      case 2: return _menuUpdates;
      case 3: return _specialOffers;
      case 4: return _messUpdates;
      case 5: return _feedbackRequests;
      default: return false;
    }
  }
  
  // Helper function to set toggle value based on index
  void _setToggleValue(int index, bool value) {
    switch (index) {
      case 0: _toggleMealNotifications(value); break;
      case 1: _togglePaymentNotifications(value); break;
      case 2: _toggleMenuNotifications(value); break;
      case 3: _toggleOfferNotifications(value); break;
      case 4: _toggleMessUpdatesNotifications(value); break;
      case 5: _toggleFeedbackNotifications(value); break;
    }
  }
  
  // Toggle all notifications at once
  void _toggleAllNotifications(bool value) {
    setState(() {
      _bookingReminder = value;
      _paymentAlerts = value;
      _menuUpdates = value;
      _specialOffers = value;
      _messUpdates = value;
      _feedbackRequests = value;
    });
    
    if (value) {
      // Enable all notifications
      _toggleMealNotifications(true);
      _togglePaymentNotifications(true);
      _toggleMenuNotifications(true);
      _toggleOfferNotifications(true);
      _toggleMessUpdatesNotifications(true);
      _toggleFeedbackNotifications(true);
    } else {
      // Disable all notifications
      _cancelAllNotifications();
    }
  }
  
  // Cancel all notifications
  Future<void> _cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'all notifications disabled',
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
  
  // Toggle meal notifications (IDs 1-3: breakfast, lunch, dinner)
  void _toggleMealNotifications(bool value) async {
    setState(() {
      _bookingReminder = value;
    });
    
    if (value) {
      // Re-enable scheduled notifications
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      // Breakfast notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'meal_channel',
          title: 'Breakfast Reminder 🍳',
          body: 'Good morning! Time for a healthy breakfast!',
        ),
        schedule: NotificationCalendar(
          hour: 8,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      // Lunch notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'meal_channel',
          title: 'Lunch Reminder 🍛',
          body: 'It\'s 1 PM! Don\'t skip your lunch!',
        ),
        schedule: NotificationCalendar(
          hour: 13,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      // Dinner notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 3,
          channelKey: 'meal_channel',
          title: 'Dinner Reminder 🍽️',
          body: 'Time for dinner! Eat well and stay healthy!',
        ),
        schedule: NotificationCalendar(
          hour: 20,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'meal reminders enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // Cancel scheduled notifications
      await AwesomeNotifications().cancelSchedule(1); // Cancel breakfast
      await AwesomeNotifications().cancelSchedule(2); // Cancel lunch
      await AwesomeNotifications().cancelSchedule(3); // Cancel dinner
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'meal reminders disabled',
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
  }
  
  // Toggle payment notifications (IDs 4-5)
  void _togglePaymentNotifications(bool value) async {
    setState(() {
      _paymentAlerts = value;
    });
    
    if (value) {
      // Enable payment notifications (scheduled once a week)
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      // Payment reminder (every Monday at 10 AM)
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 4,
          channelKey: 'meal_channel',
          title: 'Payment Reminder 💰',
          body: 'Don\'t forget to check your meal balance this week!',
        ),
        schedule: NotificationCalendar(
          weekday: DateTime.monday,
          hour: 10,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'payment notifications enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // Cancel payment notifications
      await AwesomeNotifications().cancelSchedule(4);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'payment notifications disabled',
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
  }
  
  // Toggle menu update notifications (ID 6)
  void _toggleMenuNotifications(bool value) async {
    setState(() {
      _menuUpdates = value;
    });
    
    if (value) {
      // Enable menu update notifications (Sunday evening)
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      // Menu update notification (Sunday at 6 PM)
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 6,
          channelKey: 'meal_channel',
          title: 'Weekly Menu Update 📋',
          body: 'The menu for next week has been updated. Check it out!',
        ),
        schedule: NotificationCalendar(
          weekday: DateTime.sunday,
          hour: 18,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'menu update notifications enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // Cancel menu update notifications
      await AwesomeNotifications().cancelSchedule(6);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'menu update notifications disabled',
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
  }
  
  // Toggle offer notifications (ID 7)
  void _toggleOfferNotifications(bool value) async {
    setState(() {
      _specialOffers = value;
    });
    
    // Implementation for special offers notifications
    if (value) {
      // Enable special offers notifications (monthly)
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      // Special offer notification (1st of each month)
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 7,
          channelKey: 'meal_channel',
          title: 'Special Offer! 🎁',
          body: 'Check out this month\'s special offers and discounts!',
        ),
        schedule: NotificationCalendar(
          day: 1,  // 1st day of each month
          hour: 12,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'special offer notifications enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // Cancel offer notifications
      await AwesomeNotifications().cancelSchedule(7);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'special offer notifications disabled',
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
  }
  
  // Toggle mess updates notifications (ID 8)
  void _toggleMessUpdatesNotifications(bool value) async {
    setState(() {
      _messUpdates = value;
    });
    
    // Implementation for mess updates notifications
    if (value) {
      // These would typically be push notifications rather than scheduled
      // For example purposes, we'll schedule a weekly update
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 8,
          channelKey: 'meal_channel',
          title: 'Mess Update 📢',
          body: 'Check out the latest updates and announcements from the mess!',
        ),
        schedule: NotificationCalendar(
          weekday: DateTime.wednesday,
          hour: 16,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'mess update notifications enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      await AwesomeNotifications().cancelSchedule(8);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'mess update notifications disabled',
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
  }
  
  // Toggle feedback notifications (ID 9)
  void _toggleFeedbackNotifications(bool value) async {
    setState(() {
      _feedbackRequests = value;
    });
    
    // Implementation for feedback request notifications
    if (value) {
      // Schedule feedback requests after meal times
      final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      
      // Lunch feedback (2:00 PM)
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 9,
          channelKey: 'meal_channel',
          title: 'How was your lunch? ⭐',
          body: 'Please take a moment to rate today\'s lunch!',
        ),
        schedule: NotificationCalendar(
          hour: 14,
          minute: 0,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      // Dinner feedback (9:30 PM)
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'meal_channel',
          title: 'Rate your dinner experience 🍽️',
          body: 'Your feedback helps us improve our service!',
        ),
        schedule: NotificationCalendar(
          hour: 21,
          minute: 30,
          second: 0,
          repeats: true,
          timeZone: tz,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'feedback request notifications enabled',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      await AwesomeNotifications().cancelSchedule(9);
      await AwesomeNotifications().cancelSchedule(10);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'feedback request notifications disabled',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'notifications',
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
                                'stay in the loop',
                                style: GoogleFonts.poppins(
                                  color: _textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'customize your notification preferences 🔔',
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
                    
                    // Master toggle
                    _buildMasterToggle(),
                    
                    const SizedBox(height: 25),
                    
                    // Section title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _secondaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: _secondaryAccent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'notification preferences',
                          style: GoogleFonts.poppins(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Notification toggles
                    Container(
                      decoration: BoxDecoration(
                        color: _cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notificationCategories.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          return _buildNotificationToggle(
                            title: _notificationCategories[index]['title'],
                            subtitle: _notificationCategories[index]['subtitle'],
                            icon: _notificationCategories[index]['icon'],
                            color: _notificationCategories[index]['color'],
                            value: _getToggleValue(index),
                            onChanged: (value) => _setToggleValue(index, value),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Help text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardBackgroundAltColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _accentColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'notification settings',
                                  style: GoogleFonts.poppins(
                                    color: _accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'you can also manage notification permissions in your device settings to completely turn off all notifications from this app.',
                                  style: GoogleFonts.poppins(
                                    color: _textSecondaryColor,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  
  Widget _buildMasterToggle() {
    // Calculate if any notifications are enabled
    final bool anyEnabled = _bookingReminder || _paymentAlerts || _menuUpdates || 
                            _specialOffers || _messUpdates || _feedbackRequests;
    
    // Calculate if all notifications are enabled
    final bool allEnabled = _bookingReminder && _paymentAlerts && _menuUpdates && 
                            _specialOffers && _messUpdates && _feedbackRequests;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.15),
            _backgroundColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: anyEnabled 
                    ? _primaryColor.withOpacity(0.2 + (_pulseController.value * 0.1))
                    : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  anyEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  color: anyEnabled ? _primaryColor : Colors.grey,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anyEnabled ? 'notifications on' : 'notifications off',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                Text(
                  anyEnabled 
                    ? 'you\'ll receive updates based on your preferences' 
                    : 'you won\'t receive any notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: anyEnabled,
            onChanged: _toggleAllNotifications,
            activeColor: _primaryColor,
            activeTrackColor: _primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: value ? _textColor : _textSecondaryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _textSecondaryColor.withOpacity(value ? 1.0 : 0.7),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value ? color : Colors.grey,
            size: 20,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
        activeTrackColor: color.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}