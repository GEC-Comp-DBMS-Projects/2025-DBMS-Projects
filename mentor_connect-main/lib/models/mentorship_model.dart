import 'package:cloud_firestore/cloud_firestore.dart';

class Mentorship {
  final String mentorshipId;
  final String mentorId;
  final String mentorName;
  final String mentorEmail;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String formId; // The form that was accepted
  final String formTitle;
  final DateTime acceptedAt;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime? completedAt;

  Mentorship({
    required this.mentorshipId,
    required this.mentorId,
    required this.mentorName,
    required this.mentorEmail,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.formId,
    required this.formTitle,
    required this.acceptedAt,
    this.status = 'active',
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mentorshipId': mentorshipId,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'mentorEmail': mentorEmail,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'formId': formId,
      'formTitle': formTitle,
      'acceptedAt': Timestamp.fromDate(acceptedAt),
      'status': status,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory Mentorship.fromMap(Map<String, dynamic> map) {
    return Mentorship(
      mentorshipId: map['mentorshipId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      mentorEmail: map['mentorEmail'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      formId: map['formId'] ?? '',
      formTitle: map['formTitle'] ?? '',
      acceptedAt: (map['acceptedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Mentorship copyWith({
    String? mentorshipId,
    String? mentorId,
    String? mentorName,
    String? mentorEmail,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? formId,
    String? formTitle,
    DateTime? acceptedAt,
    String? status,
    DateTime? completedAt,
  }) {
    return Mentorship(
      mentorshipId: mentorshipId ?? this.mentorshipId,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      mentorEmail: mentorEmail ?? this.mentorEmail,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      formId: formId ?? this.formId,
      formTitle: formTitle ?? this.formTitle,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
