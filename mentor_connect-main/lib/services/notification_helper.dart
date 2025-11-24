import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class NotificationHelper {
  static final _uuid = const Uuid();
  static final _firestoreService = FirestoreService();
  static final _notificationService = NotificationService();
  static final _firestore = FirebaseFirestore.instance;

  // ============ CHAT NOTIFICATIONS ============

  // Create a new chat message notification
  static Future<void> sendMessageNotification({
    required String userId,
    required String senderName,
    required String chatId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserImage,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: userId,
      type: 'message',
      title: 'New Message',
      message: 'You have a new message from $senderName',
      createdAt: DateTime.now(),
      data: {
        'chatId': chatId,
        'otherUserId': otherUserId,
        'otherUserName': otherUserName,
        'otherUserImage': otherUserImage,
      },
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ MEETING NOTIFICATIONS ============

  // Create a meeting scheduled notification
  static Future<void> sendMeetingScheduledNotification({
    required String userId,
    required String organizerName,
    required String title,
    required DateTime dateTime,
    String? meetingId,
  }) async {
    print('📧 Creating meeting notification for userId: $userId');
    print('📧 Organizer: $organizerName, Title: $title');

    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: userId,
      type: 'meeting',
      title: 'New Meeting Scheduled',
      message: '$organizerName scheduled a meeting: $title',
      createdAt: DateTime.now(),
      data: meetingId != null
          ? {'meetingId': meetingId, 'dateTime': dateTime.toIso8601String()}
          : null,
    );

    await _firestoreService.createNotification(notification);
    print('✅ Firestore notification created: ${notification.notificationId}');

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
    print('✅ Local notification shown');
  }

  // Meeting reminder notification
  static Future<void> sendMeetingReminderNotification({
    required String userId,
    required String title,
    required String message,
    String? meetingId,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: userId,
      type: 'meeting',
      title: title,
      message: message,
      createdAt: DateTime.now(),
      data: meetingId != null ? {'meetingId': meetingId} : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ FORM SUBMISSION NOTIFICATIONS ============

  // Notify mentor of new form submission
  static Future<void> sendFormSubmissionNotification({
    required String mentorId,
    required String studentName,
    required String formTitle,
    String? submissionId,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: mentorId,
      type: 'submission',
      title: 'New Application Received',
      message: '$studentName applied to your form: $formTitle',
      createdAt: DateTime.now(),
      data: submissionId != null ? {'submissionId': submissionId} : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // Notify student when form status changes
  static Future<void> sendFormStatusNotification({
    required String studentId,
    required String mentorName,
    required String status, // 'accepted', 'rejected', 'reviewed'
    required String formTitle,
    String? submissionId,
  }) async {
    String title;
    String message;

    switch (status.toLowerCase()) {
      case 'accepted':
        title = '🎉 Application Accepted!';
        message = '$mentorName accepted your application for: $formTitle';
        break;
      case 'rejected':
        title = 'Application Status Update';
        message = '$mentorName reviewed your application for: $formTitle';
        break;
      case 'reviewed':
        title = 'Application Reviewed';
        message = '$mentorName reviewed your application for: $formTitle';
        break;
      default:
        title = 'Application Status Updated';
        message = 'Your application status has been updated';
    }

    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: studentId,
      type: 'form_status',
      title: title,
      message: message,
      createdAt: DateTime.now(),
      data: submissionId != null
          ? {
              'submissionId': submissionId,
              'status': status,
            }
          : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ RESOURCE NOTIFICATIONS ============

  // Notify students when mentor posts new resource
  static Future<void> sendNewResourceNotification({
    required String studentId,
    required String mentorName,
    required String resourceTitle,
    String? resourceId,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: studentId,
      type: 'resource',
      title: 'New Resource Available',
      message: '$mentorName shared a new resource: $resourceTitle',
      createdAt: DateTime.now(),
      data: resourceId != null ? {'resourceId': resourceId} : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ REVIEW NOTIFICATIONS ============

  // Notify when someone receives a review
  static Future<void> sendReviewReceivedNotification({
    required String revieweeId,
    required String reviewerName,
    required String reviewerRole, // 'mentor' or 'student'
    required double rating,
    String? reviewId,
  }) async {
    // Get reviewee info from Firestore
    final revieweeDoc =
        await _firestore.collection('users').doc(revieweeId).get();

    final revieweeName = revieweeDoc.data()?['name'] ?? 'User';
    final revieweeRole = revieweeDoc.data()?['role'] ?? 'student';

    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: revieweeId,
      type: 'review',
      title: 'New Review Received',
      message:
          '$reviewerName (${reviewerRole == 'mentor' ? 'Mentor' : 'Student'}) rated you ${rating.toStringAsFixed(1)} stars',
      createdAt: DateTime.now(),
      data: reviewId != null
          ? {
              'reviewId': reviewId,
              'rating': rating.toString(),
              'revieweeId': revieweeId,
              'revieweeName': revieweeName,
              'revieweeRole': revieweeRole,
            }
          : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ MENTORSHIP NOTIFICATIONS ============

  // Notify student when mentorship is established
  static Future<void> sendMentorshipStartedNotification({
    required String studentId,
    required String mentorName,
    String? mentorshipId,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: studentId,
      type: 'mentorship',
      title: '🎓 Mentorship Started!',
      message:
          'You are now a mentee of $mentorName. Good luck on your learning journey!',
      createdAt: DateTime.now(),
      data: mentorshipId != null ? {'mentorshipId': mentorshipId} : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // Notify mentor when they accept a student
  static Future<void> sendNewMenteeNotification({
    required String mentorId,
    required String studentName,
    String? mentorshipId,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: mentorId,
      type: 'mentorship',
      title: 'New Mentee Added',
      message:
          '$studentName is now your mentee. Start guiding them to success!',
      createdAt: DateTime.now(),
      data: mentorshipId != null ? {'mentorshipId': mentorshipId} : null,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }

  // ============ GENERAL NOTIFICATIONS ============

  // Create a general notification
  static Future<void> sendGeneralNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      notificationId: _uuid.v4(),
      userId: userId,
      type: type ?? 'general',
      title: title,
      message: message,
      createdAt: DateTime.now(),
      data: data,
    );

    await _firestoreService.createNotification(notification);

    // Also show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
      payload: notification.notificationId,
    );
  }
}
