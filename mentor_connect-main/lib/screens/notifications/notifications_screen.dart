import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/notification_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to view notifications')),
      );
    }

    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Mark all as read button
          StreamBuilder<List<NotificationModel>>(
            stream: firestoreService.getUserNotifications(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final hasUnread = snapshot.data!.any((n) => !n.isRead);

              if (!hasUnread) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: () async {
                  await firestoreService.markAllNotificationsAsRead(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message: 'You don\'t have any notifications yet',
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(context, notification),
                onDismiss: () async {
                  await firestoreService
                      .deleteNotification(notification.notificationId);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) async {
    // Mark as read
    if (!notification.isRead) {
      await FirestoreService()
          .markNotificationAsRead(notification.notificationId);
    }

    // Navigate based on notification type
    if (!context.mounted) return;

    switch (notification.type) {
      case 'message':
        if (notification.data?['chatId'] != null &&
            notification.data?['otherUserId'] != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.chatDetail,
            arguments: {
              'chatId': notification.data!['chatId'],
              'otherUserId': notification.data!['otherUserId'],
              'otherUserName': notification.data?['otherUserName'] ?? 'User',
              'otherUserImage': notification.data?['otherUserImage'],
            },
          );
        }
        break;

      case 'meeting':
        // Navigate to meetings screen
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user?.isMentor == true) {
          // Mentor doesn't have a meetings screen yet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('View meetings from dashboard')),
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.studentMeetings);
        }
        break;

      case 'form':
      case 'submission':
        // Navigate to submissions
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user?.isMentor == true) {
          Navigator.pushNamed(context, AppRoutes.formSubmissions);
        } else {
          Navigator.pushNamed(context, AppRoutes.mySubmissions);
        }
        break;

      case 'review':
        // Navigate to reviews
        if (notification.data != null &&
            notification.data!['revieweeId'] != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.reviews,
            arguments: {
              'userId': notification.data!['revieweeId'],
              'userName': notification.data!['revieweeName'] ?? 'User',
              'userRole': notification.data!['revieweeRole'] ?? 'student',
            },
          );
        }
        break;

      default:
        // General notification - no specific action
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: _getNotificationIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
        tileColor: notification.isRead
            ? null
            : AppTheme.primaryColor.withOpacity(0.05),
      ),
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case 'message':
        iconData = Icons.message;
        color = AppTheme.primaryColor;
        break;
      case 'meeting':
        iconData = Icons.event;
        color = AppTheme.successColor;
        break;
      case 'form':
        iconData = Icons.description;
        color = AppTheme.mentorColor;
        break;
      case 'submission':
        iconData = Icons.assignment_turned_in;
        color = AppTheme.studentColor;
        break;
      case 'review':
        iconData = Icons.star;
        color = Colors.amber;
        break;
      default:
        iconData = Icons.notifications;
        color = AppTheme.textSecondary;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
