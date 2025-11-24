import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';
import 'notification_helper.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create a review
  Future<void> createReview({
    required String reviewerId,
    required String reviewerName,
    required String revieweeId,
    required String revieweeName,
    required String reviewerRole,
    required String revieweeRole,
    required double rating,
    String? comment,
  }) async {
    try {
      print('⭐ Creating review:');
      print('⭐ Reviewer: $reviewerName (ID: $reviewerId, Role: $reviewerRole)');
      print('⭐ Reviewee: $revieweeName (ID: $revieweeId, Role: $revieweeRole)');
      print('⭐ Rating: $rating');

      final review = Review(
        reviewId: _uuid.v4(),
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        revieweeId: revieweeId,
        revieweeName: revieweeName,
        reviewerRole: reviewerRole,
        revieweeRole: revieweeRole,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('reviews')
          .doc(review.reviewId)
          .set(review.toMap());

      print('⭐ Review saved with ID: ${review.reviewId}');

      // Update average rating for the reviewee
      await _updateUserRating(revieweeId);

      // Send notification to the reviewee
      await NotificationHelper.sendReviewReceivedNotification(
        revieweeId: revieweeId,
        reviewerName: reviewerName,
        reviewerRole: reviewerRole,
        rating: rating,
        reviewId: review.reviewId,
      );

      print('⭐ Review creation complete!');
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  // Update user's average rating
  Future<void> _updateUserRating(String userId) async {
    try {
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
    } catch (e) {
      print('Error updating user rating: $e');
    }
  }

  // Get reviews for a specific user (as reviewee)
  Stream<List<Review>> getReviewsForUser(String userId) {
    print('📊 Fetching reviews for userId (as reviewee): $userId');
    return _firestore
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📊 Found ${snapshot.docs.length} reviews for user: $userId');
      for (var doc in snapshot.docs) {
        print('📊 Review: ${doc.data()}');
      }
      return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
    });
  }

  // Get reviews written by a user (as reviewer)
  Stream<List<Review>> getReviewsByUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('reviewerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  // Check if user has already reviewed another user
  Future<bool> hasUserReviewedUser(String reviewerId, String revieweeId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('reviewerId', isEqualTo: reviewerId)
          .where('revieweeId', isEqualTo: revieweeId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking review status: $e');
      return false;
    }
  }

  // Get average rating for a user
  Future<double> getAverageRating(String userId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .get();

      if (reviews.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in reviews.docs) {
        totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
      }

      return totalRating / reviews.docs.length;
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Get total review count for a user
  Future<int> getReviewCount(String userId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .get();

      return reviews.docs.length;
    } catch (e) {
      print('Error getting review count: $e');
      return 0;
    }
  }

  // Delete a review (if needed)
  Future<void> deleteReview(String reviewId, String revieweeId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update ratings after deletion
      await _updateUserRating(revieweeId);
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
