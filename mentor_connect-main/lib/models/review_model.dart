import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String reviewerId; // Person who wrote the review
  final String reviewerName;
  final String revieweeId; // Person being reviewed
  final String revieweeName;
  final String reviewerRole; // 'mentor' or 'student'
  final String revieweeRole; // 'mentor' or 'student'
  final double rating; // 1.0 to 5.0
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.reviewerRole,
    required this.revieweeRole,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  // Helper getters for backward compatibility
  String get mentorId => revieweeRole == 'mentor' ? revieweeId : reviewerId;
  String get studentId => revieweeRole == 'student' ? revieweeId : reviewerId;
  String get studentName =>
      revieweeRole == 'student' ? revieweeName : reviewerName;

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'reviewerRole': reviewerRole,
      'revieweeRole': revieweeRole,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewId: map['reviewId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      revieweeName: map['revieweeName'] ?? '',
      reviewerRole: map['reviewerRole'] ?? '',
      revieweeRole: map['revieweeRole'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Review copyWith({
    String? reviewId,
    String? reviewerId,
    String? reviewerName,
    String? revieweeId,
    String? revieweeName,
    String? reviewerRole,
    String? revieweeRole,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      reviewId: reviewId ?? this.reviewId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      revieweeId: revieweeId ?? this.revieweeId,
      revieweeName: revieweeName ?? this.revieweeName,
      reviewerRole: reviewerRole ?? this.reviewerRole,
      revieweeRole: revieweeRole ?? this.revieweeRole,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
