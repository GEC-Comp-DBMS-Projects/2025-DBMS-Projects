import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'mentor' or 'student'
  final String? profileImage;
  final String? bio;
  final String? phone;
  final List<String> expertise; // For mentors
  final List<String> interests; // For students
  final DateTime createdAt;
  final bool emailVerified;
  final double? rating; // Average rating for mentors
  final int? totalRatings; // Total number of ratings

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    this.bio,
    this.phone,
    this.expertise = const [],
    this.interests = const [],
    required this.createdAt,
    this.emailVerified = false,
    this.rating,
    this.totalRatings,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'bio': bio,
      'phone': phone,
      'expertise': expertise,
      'interests': interests,
      'createdAt': Timestamp.fromDate(createdAt),
      'emailVerified': emailVerified,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      profileImage: map['profileImage'],
      bio: map['bio'],
      phone: map['phone'],
      expertise: List<String>.from(map['expertise'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      emailVerified: map['emailVerified'] ?? false,
      rating: map['rating']?.toDouble(),
      totalRatings: map['totalRatings'],
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    String? bio,
    String? phone,
    List<String>? expertise,
    List<String>? interests,
    DateTime? createdAt,
    bool? emailVerified,
    double? rating,
    int? totalRatings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      expertise: expertise ?? this.expertise,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }

  bool get isMentor => role == 'mentor';
  bool get isStudent => role == 'student';
}
