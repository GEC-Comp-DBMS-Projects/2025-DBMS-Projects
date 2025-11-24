import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/create_notifications.dart';
import 'package:frontend/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final String id;
  final String subject;
  final String message;
  bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.subject,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      subject: json['subject'] ?? 'No Subject',
      message: json['message'] ?? 'No Message',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);
  final Color lightTeal = const Color(0xFFEBFBFA);

  bool _isTpo = false;
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];
  String _selectedFilter = 'All';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initializePage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    if (mounted) setState(() => _isLoading = true);
    await _checkUserRole();
    await _loadNotifications();
    if (mounted) {
      setState(() => _isLoading = false);
      _animationController.forward();
    }
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role == 'tpo') {
      if (mounted) setState(() => _isTpo = true);
    }
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? '';
  }

  Future<void> _loadNotifications() async {
    final token = await getToken();
    final role = await getRole();
    if (token.isEmpty) {
      if (mounted) {
        AppToast.error(context, 'Authentication token not found.');
      }
      return;
    }
    final url;
      url = Uri.parse(
        'https://campusnest-backend-lkue.onrender.com/api/v1/$role/notifications',
      );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        final List<dynamic> notificationList = data['notifications'] ?? [];

        setState(() {
          _notifications = notificationList
              .map((json) => NotificationItem.fromJson(json))
              .toList();
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      } else {
        AppToast.error(context, 'Failed to load notifications.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'An error occurred: $e');
      }
    }
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    } else if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    } else {
      return _notifications.where((n) => n.isRead).toList();
    }
  }

  // List<NotificationItem> get _filteredNotifications {
  //   if (_selectedFilter == 'All') {
  //     return _notifications;
  //   } else if (_selectedFilter == 'Unread') {
  //     return _notifications.where((n) => !n.isRead).toList();
  //   } else {
  //     return _notifications.where((n) => n.isRead).toList();
  //   }
  // }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, primaryColor, darkColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_isLoading) _buildStatsCards(),
              _buildFilterTabs(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(lightColor),
                        ),
                      )
                    : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isTpo ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: darkColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount new notification${_unreadCount > 1 ? 's' : ''}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: lightColor.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (_notifications.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: lightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.mark_email_read, color: lightColor),
                onPressed: () {
                  setState(() {
                    for (var notification in _notifications) {
                      notification.isRead = true;
                    }
                  });
                  AppToast.success(context, 'All notifications marked as read.');
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.notifications_active,
              'Total',
              _notifications.length.toString(),
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.mark_email_unread,
              'Unread',
              _unreadCount.toString(),
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.done_all,
              'Read',
              (_notifications.length - _unreadCount).toString(),
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: grayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Unread', 'Read'];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? lightColor : lightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? lightColor
                          : lightColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? primaryColor : lightColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: _buildNotificationCard(_filteredNotifications[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(notification.createdAt) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isYesterday =
        DateFormat(
          'yyyy-MM-dd',
        ).format(notification.createdAt.add(Duration(days: 1))) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    String timeText;
    if (isToday) {
      timeText = DateFormat('h:mm a').format(notification.createdAt);
    } else if (isYesterday) {
      timeText = 'Yesterday';
    } else {
      timeText = DateFormat('d MMM').format(notification.createdAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border.all(color: primaryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailPage(
                  notification: notification,
                  primaryColor: primaryColor,
                  darkColor: darkColor,
                  lightColor: lightColor,
                  grayColor: grayColor,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: notification.isRead
                          ? [
                              grayColor.withOpacity(0.3),
                              grayColor.withOpacity(0.2),
                            ]
                          : [primaryColor, darkColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.subject),
                    color: notification.isRead ? grayColor : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.subject,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: darkColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: grayColor,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: grayColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeText,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: grayColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: grayColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String subject) {
    final lowerSubject = subject.toLowerCase();
    if (lowerSubject.contains('job') || lowerSubject.contains('opening')) {
      return Icons.work;
    } else if (lowerSubject.contains('placement') ||
        lowerSubject.contains('drive')) {
      return Icons.business_center;
    } else if (lowerSubject.contains('interview')) {
      return Icons.people;
    } else if (lowerSubject.contains('deadline') ||
        lowerSubject.contains('reminder')) {
      return Icons.alarm;
    } else if (lowerSubject.contains('update')) {
      return Icons.update;
    } else {
      return Icons.notifications;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.notifications_none, size: 64, color: lightColor),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'All'
                ? 'No Notifications'
                : 'No $_selectedFilter Notifications',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: lightColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'All'
                ? 'You\'re all caught up!'
                : 'Check other tabs for notifications',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: lightColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightColor,
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateNotificationPage(),
        ),
      );
      if (result == true) {
        _loadNotifications();
      }
    },
      icon: Icon(Icons.add),
      label: Text('Create'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    );
  }
}

// Notification Detail Page
class NotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;
  final Color grayColor;
  final Color lightTeal = const Color(0xFFEBFBFA);

  const NotificationDetailPage({
    super.key,
    required this.notification,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
    required this.grayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightTeal,
              primaryColor,
              darkColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: lightColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: lightColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Notification Details',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: lightColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, darkColor],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.subject,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: darkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'd MMMM yyyy, h:mm a',
                                    ).format(notification.createdAt),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: grayColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: grayColor.withOpacity(0.2)),
                        const SizedBox(height: 24),
                        Text(
                          'Message',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.message,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              height: 1.6,
                              color: darkColor.withOpacity(0.8),
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
        ),
      ),
    );
  }
}
