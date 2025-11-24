import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/mentorship_form_model.dart';
import '../models/form_submission_model.dart';
import '../models/meeting_model.dart';
import '../models/resource_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER OPERATIONS ============

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Get all mentors
  Future<List<UserModel>> getAllMentors() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mentor')
        .get();

    // Sort by rating in memory instead of Firestore
    final mentors =
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    mentors.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return mentors;
  }

  // Search mentors by expertise
  Future<List<UserModel>> searchMentors(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mentor')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((mentor) =>
            mentor.name.toLowerCase().contains(query.toLowerCase()) ||
            mentor.expertise
                .any((exp) => exp.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  // ============ MENTORSHIP FORM OPERATIONS ============

  Future<void> createForm(MentorshipForm form) async {
    await _firestore
        .collection('mentorship_forms')
        .doc(form.formId)
        .set(form.toMap());
  }

  Future<void> updateForm(String formId, Map<String, dynamic> data) async {
    await _firestore.collection('mentorship_forms').doc(formId).update(data);
  }

  Future<void> deleteForm(String formId) async {
    await _firestore.collection('mentorship_forms').doc(formId).delete();
  }

  Future<MentorshipForm?> getForm(String formId) async {
    final doc =
        await _firestore.collection('mentorship_forms').doc(formId).get();
    if (doc.exists) {
      return MentorshipForm.fromMap(doc.data()!);
    }
    return null;
  }

  // Get all active forms
  Stream<List<MentorshipForm>> getActiveForms() {
    return _firestore
        .collection('mentorship_forms')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MentorshipForm.fromMap(doc.data()))
            .toList());
  }

  // Get forms by mentor
  Stream<List<MentorshipForm>> getFormsByMentor(String mentorId) {
    return _firestore
        .collection('mentorship_forms')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MentorshipForm.fromMap(doc.data()))
            .toList());
  }

  // ============ FORM SUBMISSION OPERATIONS ============

  Future<void> submitForm(FormSubmission submission) async {
    await _firestore
        .collection('form_submissions')
        .doc(submission.submissionId)
        .set(submission.toMap());
  }

  Future<void> updateSubmission(
      String submissionId, Map<String, dynamic> data) async {
    await _firestore
        .collection('form_submissions')
        .doc(submissionId)
        .update(data);
  }

  // Check if student has already submitted a form to a mentor
  Future<bool> hasStudentSubmittedToMentor(
      String studentId, String mentorId) async {
    final snapshot = await _firestore
        .collection('form_submissions')
        .where('studentId', isEqualTo: studentId)
        .where('mentorId', isEqualTo: mentorId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get submissions by student
  Stream<List<FormSubmission>> getSubmissionsByStudent(String studentId) {
    return _firestore
        .collection('form_submissions')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FormSubmission.fromMap(doc.data()))
            .toList());
  }

  // Get submissions for mentor
  Stream<List<FormSubmission>> getSubmissionsForMentor(String mentorId) {
    return _firestore
        .collection('form_submissions')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FormSubmission.fromMap(doc.data()))
            .toList());
  }

  // ============ MEETING OPERATIONS ============

  Future<void> createMeeting(Meeting meeting) async {
    await _firestore
        .collection('meetings')
        .doc(meeting.meetingId)
        .set(meeting.toMap());
  }

  Future<void> updateMeeting(
      String meetingId, Map<String, dynamic> data) async {
    await _firestore.collection('meetings').doc(meetingId).update(data);
  }

  Future<void> deleteMeeting(String meetingId) async {
    await _firestore.collection('meetings').doc(meetingId).delete();
  }

  // Get meetings for user (mentor or student)
  Stream<List<Meeting>> getMeetingsForUser(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList());
  }

  // Get upcoming meetings
  Stream<List<Meeting>> getUpcomingMeetings(String userId) {
    return _firestore
        .collection('meetings')
        .where('participants', arrayContains: userId)
        .where('dateTime', isGreaterThan: Timestamp.now())
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList());
  }

  // ============ RESOURCE OPERATIONS ============

  Future<void> createResource(Resource resource) async {
    await _firestore
        .collection('resources')
        .doc(resource.resourceId)
        .set(resource.toMap());
  }

  Future<void> updateResource(
      String resourceId, Map<String, dynamic> data) async {
    await _firestore.collection('resources').doc(resourceId).update(data);
  }

  Future<void> deleteResource(String resourceId) async {
    await _firestore.collection('resources').doc(resourceId).delete();
  }

  // Get resources by mentor
  Stream<List<Resource>> getResourcesByMentor(String mentorId) {
    return _firestore
        .collection('resources')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList());
  }

  // Get all resources (for students)
  Stream<List<Resource>> getAllResources() {
    return _firestore
        .collection('resources')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList());
  }

  // Increment resource download count
  Future<void> incrementDownloadCount(String resourceId) async {
    await _firestore.collection('resources').doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  // ============ REVIEW OPERATIONS ============

  Future<void> createReview(Review review) async {
    await _firestore
        .collection('reviews')
        .doc(review.reviewId)
        .set(review.toMap());

    // Update reviewee's average rating
    await _updateUserRating(review.revieweeId);
  }

  Future<void> _updateUserRating(String userId) async {
    final reviews = await _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .get();

    if (reviews.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in reviews.docs) {
        totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
      }

      double averageRating = totalRating / reviews.docs.length;

      await _firestore.collection('users').doc(userId).update({
        'rating': averageRating,
        'totalRatings': reviews.docs.length,
      });
    }
  }

  // Get reviews for user (as reviewee)
  Stream<List<Review>> getReviewsForUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  // Get reviews for mentor (backward compatibility)
  Stream<List<Review>> getReviewsForMentor(String mentorId) {
    return getReviewsForUser(mentorId);
  }

  // Get reviews by mentor (alias for getReviewsForMentor)
  Stream<List<Review>> getReviewsByMentor(String mentorId) {
    return getReviewsForMentor(mentorId);
  }

  // Check if user has already reviewed another user
  Future<bool> hasUserReviewedUser(String reviewerId, String revieweeId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewerId', isEqualTo: reviewerId)
        .where('revieweeId', isEqualTo: revieweeId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Legacy method for backward compatibility
  Future<bool> hasStudentReviewedMentor(
      String studentId, String mentorId) async {
    return hasUserReviewedUser(studentId, mentorId);
  }

  // ============ NOTIFICATION OPERATIONS ============

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.notificationId)
        .set(notification.toMap());
  }

  // Get user's notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Get unread notification count
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
