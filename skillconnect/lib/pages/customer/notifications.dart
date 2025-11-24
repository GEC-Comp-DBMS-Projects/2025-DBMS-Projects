import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

// --- Data Model for a Notification ---
class AppNotification {
  final String id; // Added document ID
  final String title;
  final String message;
  final Timestamp time;
  final String type; // e.g., 'job_accepted', 'job_completed'
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id, // Assign the document ID
      title: data['title'] ?? 'No Title',
      message: data['message'] ?? 'No Message',
      time: data['time'] ?? Timestamp.now(),
      type: data['type'] ?? 'general',
      isRead: data['status'] == 'read',
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  Stream<QuerySnapshot>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _notificationsStream = FirebaseFirestore.instance
          .collection('notifications')
          .where('receiver_id', isEqualTo: userId)
          .orderBy('time', descending: true)
          .snapshots();
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'status': 'read'});
    } catch (e) {
      if (kDebugMode) {
        print("Error marking notification as read: $e");
      }
      // Optionally show a snackbar to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs
              .map((doc) => AppNotification.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationTile(notifications[index]);
            },
          );
        },
      ),
    );
  }

  // --- MODIFIED: Implemented onTap functionality ---
  Widget _buildNotificationTile(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : lightBlue.withValues(alpha: 0.05),
        border: Border(
          left: BorderSide(
            color: notification.isRead ? Colors.transparent : lightBlue,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        leading: _getIconForType(notification.type),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
        ),
        subtitle: Text(notification.message),
        trailing: Text(
          timeago.format(notification.time.toDate()),
          style: const TextStyle(fontSize: 12, color: grayBlue),
        ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Widget _getIconForType(String type) {
    IconData iconData;
    Color color;
    switch (type) {
      case 'job_accepted':
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'job_completed':
        iconData = Icons.task_alt;
        color = lightBlue;
        break;
      case 'job_cancelled':
        iconData = Icons.cancel_outlined;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications_outlined;
        color = grayBlue;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: grayBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your recent alerts will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.orangeAccent),
            SizedBox(height: 20),
            Text(
              'Database Index Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "To see your notifications, a Firestore index is needed. Please check your debug console for a URL to create it, or create it manually.",
              textAlign: TextAlign.center,
              style: TextStyle(color: grayBlue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
