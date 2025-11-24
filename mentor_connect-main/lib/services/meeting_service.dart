import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorship_app/models/meeting_model.dart';
import 'package:mentorship_app/services/notification_helper.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new meeting request
  Future<String> createMeeting({
    required String mentorId,
    required String mentorName,
    required String studentId,
    required String studentName,
    required String title,
    required String description,
    required DateTime dateTime,
    required int duration,
    required String location,
    required String meetingType,
    required String requestedBy,
  }) async {
    try {
      final docRef = _firestore.collection('meetings').doc();
      final meeting = Meeting(
        meetingId: docRef.id,
        mentorId: mentorId,
        mentorName: mentorName,
        studentId: studentId,
        studentName: studentName,
        title: title,
        description: description,
        dateTime: dateTime,
        duration: duration,
        location: location,
        meetingType: meetingType,
        status: 'pending',
        requestedBy: requestedBy,
        createdAt: DateTime.now(),
      );

      await docRef.set(meeting.toMap());

      // Send notification to the other party
      final recipientId = requestedBy == 'mentor' ? studentId : mentorId;
      final requesterName = requestedBy == 'mentor' ? mentorName : studentName;

      print('🔔 Meeting created by: $requestedBy');
      print('🔔 Mentor ID: $mentorId, Student ID: $studentId');
      print('🔔 Notification will be sent to: $recipientId (recipient)');
      print('🔔 Requester name: $requesterName');

      await NotificationHelper.sendMeetingScheduledNotification(
        userId: recipientId,
        organizerName: requesterName,
        title: title,
        dateTime: dateTime,
        meetingId: docRef.id,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create meeting: $e');
    }
  }

  // Approve a meeting request
  Future<void> approveMeeting({
    required String meetingId,
    String? responseNote,
  }) async {
    try {
      final meetingDoc =
          await _firestore.collection('meetings').doc(meetingId).get();
      if (!meetingDoc.exists) throw Exception('Meeting not found');

      final meeting = Meeting.fromMap(meetingDoc.data()!);

      await _firestore.collection('meetings').doc(meetingId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
        'responseNote': responseNote,
      });

      // Send notification to requester
      final requesterId = meeting.requestedBy == 'mentor'
          ? meeting.mentorId
          : meeting.studentId;
      final approverName = meeting.requestedBy == 'mentor'
          ? meeting.studentName
          : meeting.mentorName;

      await NotificationHelper.sendMeetingReminderNotification(
        userId: requesterId,
        title: 'Meeting Accepted',
        message:
            '$approverName accepted your meeting request: ${meeting.title}',
        meetingId: meetingId,
      );
    } catch (e) {
      throw Exception('Failed to approve meeting: $e');
    }
  }

  // Decline a meeting request
  Future<void> declineMeeting({
    required String meetingId,
    required String responseNote,
  }) async {
    try {
      final meetingDoc =
          await _firestore.collection('meetings').doc(meetingId).get();
      if (!meetingDoc.exists) throw Exception('Meeting not found');

      final meeting = Meeting.fromMap(meetingDoc.data()!);

      await _firestore.collection('meetings').doc(meetingId).update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
        'responseNote': responseNote,
      });

      // Send notification to requester
      final requesterId = meeting.requestedBy == 'mentor'
          ? meeting.mentorId
          : meeting.studentId;
      final declinerName = meeting.requestedBy == 'mentor'
          ? meeting.studentName
          : meeting.mentorName;

      await NotificationHelper.sendMeetingReminderNotification(
        userId: requesterId,
        title: 'Meeting Declined',
        message:
            '$declinerName declined your meeting request: ${meeting.title}',
        meetingId: meetingId,
      );
    } catch (e) {
      throw Exception('Failed to decline meeting: $e');
    }
  }

  // Postpone a meeting
  Future<void> postponeMeeting({
    required String meetingId,
    required DateTime newDateTime,
    String? responseNote,
  }) async {
    try {
      final meetingDoc =
          await _firestore.collection('meetings').doc(meetingId).get();
      if (!meetingDoc.exists) throw Exception('Meeting not found');

      final meeting = Meeting.fromMap(meetingDoc.data()!);

      await _firestore.collection('meetings').doc(meetingId).update({
        'originalDateTime': meeting.dateTime,
        'dateTime': Timestamp.fromDate(newDateTime),
        'status': 'postponed',
        'respondedAt': FieldValue.serverTimestamp(),
        'responseNote': responseNote,
      });

      // Send notification to both parties
      await NotificationHelper.sendMeetingReminderNotification(
        userId: meeting.mentorId,
        title: 'Meeting Postponed',
        message:
            'Meeting "${meeting.title}" has been postponed to ${_formatDateTime(newDateTime)}',
        meetingId: meetingId,
      );

      await NotificationHelper.sendMeetingReminderNotification(
        userId: meeting.studentId,
        title: 'Meeting Postponed',
        message:
            'Meeting "${meeting.title}" has been postponed to ${_formatDateTime(newDateTime)}',
        meetingId: meetingId,
      );
    } catch (e) {
      throw Exception('Failed to postpone meeting: $e');
    }
  }

  // Cancel a meeting
  Future<void> cancelMeeting({
    required String meetingId,
    required String cancelReason,
    required String cancelledBy,
  }) async {
    try {
      final meetingDoc =
          await _firestore.collection('meetings').doc(meetingId).get();
      if (!meetingDoc.exists) throw Exception('Meeting not found');

      final meeting = Meeting.fromMap(meetingDoc.data()!);

      await _firestore.collection('meetings').doc(meetingId).update({
        'status': 'cancelled',
        'cancelReason': cancelReason,
      });

      // Send notification to the other party
      final otherUserId = cancelledBy == meeting.mentorId
          ? meeting.studentId
          : meeting.mentorId;
      final cancellerName = cancelledBy == meeting.mentorId
          ? meeting.mentorName
          : meeting.studentName;

      await NotificationHelper.sendMeetingReminderNotification(
        userId: otherUserId,
        title: 'Meeting Cancelled',
        message:
            '$cancellerName cancelled the meeting: ${meeting.title}. Reason: $cancelReason',
        meetingId: meetingId,
      );
    } catch (e) {
      throw Exception('Failed to cancel meeting: $e');
    }
  }

  // Complete a meeting
  Future<void> completeMeeting({
    required String meetingId,
  }) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'status': 'completed',
      });
    } catch (e) {
      throw Exception('Failed to complete meeting: $e');
    }
  }

  // Get meeting by ID
  Future<Meeting?> getMeetingById(String meetingId) async {
    try {
      final doc = await _firestore.collection('meetings').doc(meetingId).get();
      if (doc.exists) {
        return Meeting.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get meeting: $e');
    }
  }

  // Get user's meetings stream
  Stream<List<Meeting>> getUserMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList());
  }

  // Get pending meetings for a user
  Stream<List<Meeting>> getPendingMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
                .map((doc) => Meeting.fromMap(doc.data()))
                .where((meeting) {
              // Only show pending meetings where user is the recipient
              if (meeting.requestedBy == 'mentor') {
                return meeting.studentId == userId;
              } else {
                return meeting.mentorId == userId;
              }
            }).toList());
  }

  // Get upcoming accepted meetings
  Stream<List<Meeting>> getUpcomingMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .where('status', whereIn: ['accepted', 'postponed'])
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meeting.fromMap(doc.data()))
            .where((meeting) => meeting.isUpcoming || meeting.isOngoing)
            .toList());
  }

  // Get past meetings
  Stream<List<Meeting>> getPastMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meeting.fromMap(doc.data()))
            .where((meeting) =>
                meeting.isPast ||
                meeting.isCompleted ||
                meeting.isCancelled ||
                meeting.isDeclined)
            .toList());
  }

  // Get meetings by status
  Stream<List<Meeting>> getMeetingsByStatus(String userId, String status) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: status)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList());
  }

  // Delete a meeting (only if pending)
  Future<void> deleteMeeting(String meetingId) async {
    try {
      final meetingDoc =
          await _firestore.collection('meetings').doc(meetingId).get();
      if (!meetingDoc.exists) throw Exception('Meeting not found');

      final meeting = Meeting.fromMap(meetingDoc.data()!);
      if (meeting.status != 'pending') {
        throw Exception('Only pending meetings can be deleted');
      }

      await _firestore.collection('meetings').doc(meetingId).delete();
    } catch (e) {
      throw Exception('Failed to delete meeting: $e');
    }
  }

  // Helper method to format date time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get upcoming meeting count for a user
  Future<int> getUserMeetingCount(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('meetings')
          .where('participants', arrayContains: userId)
          .where('status', whereIn: ['pending', 'accepted']).get();

      // Filter for future meetings
      final upcomingMeetings = snapshot.docs.where((doc) {
        final meeting = Meeting.fromMap(doc.data());
        return meeting.dateTime.isAfter(now);
      }).length;

      return upcomingMeetings;
    } catch (e) {
      print('Error getting meeting count: $e');
      return 0;
    }
  }
}
