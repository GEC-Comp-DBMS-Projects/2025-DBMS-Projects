import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentorship_model.dart';
import '../models/form_submission_model.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'notification_helper.dart';

class MentorshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Create mentorship relationship when form is accepted
  Future<void> createMentorship(
      FormSubmission submission, UserModel mentor) async {
    final mentorshipId = _uuid.v4();

    final mentorship = Mentorship(
      mentorshipId: mentorshipId,
      mentorId: submission.mentorId,
      mentorName: mentor.name,
      mentorEmail: mentor.email,
      studentId: submission.studentId,
      studentName: submission.studentName,
      studentEmail: submission.studentEmail,
      formId: submission.formId,
      formTitle: submission.formTitle,
      acceptedAt: DateTime.now(),
      status: 'active',
    );

    await _firestore
        .collection('mentorships')
        .doc(mentorshipId)
        .set(mentorship.toMap());

    // Send notifications to both student and mentor
    await NotificationHelper.sendMentorshipStartedNotification(
      studentId: submission.studentId,
      mentorName: mentor.name,
      mentorshipId: mentorshipId,
    );

    await NotificationHelper.sendNewMenteeNotification(
      mentorId: submission.mentorId,
      studentName: submission.studentName,
      mentorshipId: mentorshipId,
    );
  }

  // Get all mentees for a mentor
  Stream<List<Mentorship>> getMentorMentees(String mentorId) {
    return _firestore
        .collection('mentorships')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'active')
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mentorship.fromMap(doc.data()))
            .toList());
  }

  // Get all mentors for a student
  Stream<List<Mentorship>> getStudentMentors(String studentId) {
    return _firestore
        .collection('mentorships')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mentorship.fromMap(doc.data()))
            .toList());
  }

  // Get accepted mentor IDs for a student (for resource filtering)
  Future<List<String>> getAcceptedMentorIds(String studentId) async {
    final snapshot = await _firestore
        .collection('mentorships')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['mentorId'] as String)
        .toList();
  }

  // Get accepted student IDs for a mentor (for resource sharing)
  Future<List<String>> getAcceptedStudentIds(String mentorId) async {
    final snapshot = await _firestore
        .collection('mentorships')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['studentId'] as String)
        .toList();
  }

  // Check if a mentorship exists between mentor and student
  Future<bool> mentorshipExists(String mentorId, String studentId) async {
    final snapshot = await _firestore
        .collection('mentorships')
        .where('mentorId', isEqualTo: mentorId)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Check if user has active mentorship with another user (works for both mentor and student)
  Future<bool> hasActiveMentorship(String userId, String otherUserId) async {
    // Check if userId is student and otherUserId is mentor
    final studentMentorship = await _firestore
        .collection('mentorships')
        .where('studentId', isEqualTo: userId)
        .where('mentorId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (studentMentorship.docs.isNotEmpty) return true;

    // Check if userId is mentor and otherUserId is student
    final mentorMentorship = await _firestore
        .collection('mentorships')
        .where('mentorId', isEqualTo: userId)
        .where('studentId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    return mentorMentorship.docs.isNotEmpty;
  }

  // Complete a mentorship
  Future<void> completeMentorship(String mentorshipId) async {
    await _firestore.collection('mentorships').doc(mentorshipId).update({
      'status': 'completed',
      'completedAt': Timestamp.now(),
    });
  }

  // Cancel a mentorship
  Future<void> cancelMentorship(String mentorshipId) async {
    await _firestore.collection('mentorships').doc(mentorshipId).update({
      'status': 'cancelled',
      'completedAt': Timestamp.now(),
    });
  }

  // Get mentorship count for stats
  Future<int> getMentorshipCount(String userId, String userRole) async {
    Query query;

    if (userRole == 'mentor') {
      query = _firestore
          .collection('mentorships')
          .where('mentorId', isEqualTo: userId)
          .where('status', isEqualTo: 'active');
    } else {
      query = _firestore
          .collection('mentorships')
          .where('studentId', isEqualTo: userId)
          .where('status', isEqualTo: 'active');
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }
}
