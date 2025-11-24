import 'package:cloud_firestore/cloud_firestore.dart';

class FormSubmission {
  final String submissionId;
  final String formId;
  final String formTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String mentorId;
  final Map<String, dynamic> responses; // questionId: answer
  final String status; // 'pending', 'reviewed', 'accepted', 'rejected'
  final DateTime submittedAt;
  final String? mentorFeedback;
  final DateTime? reviewedAt;

  FormSubmission({
    required this.submissionId,
    required this.formId,
    required this.formTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.mentorId,
    required this.responses,
    this.status = 'pending',
    required this.submittedAt,
    this.mentorFeedback,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'submissionId': submissionId,
      'formId': formId,
      'formTitle': formTitle,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'mentorId': mentorId,
      'responses': responses,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'mentorFeedback': mentorFeedback,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  factory FormSubmission.fromMap(Map<String, dynamic> map) {
    return FormSubmission(
      submissionId: map['submissionId'] ?? '',
      formId: map['formId'] ?? '',
      formTitle: map['formTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      mentorId: map['mentorId'] ?? '',
      responses: Map<String, dynamic>.from(map['responses'] ?? {}),
      status: map['status'] ?? 'pending',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      mentorFeedback: map['mentorFeedback'],
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  FormSubmission copyWith({
    String? submissionId,
    String? formId,
    String? formTitle,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? mentorId,
    Map<String, dynamic>? responses,
    String? status,
    DateTime? submittedAt,
    String? mentorFeedback,
    DateTime? reviewedAt,
  }) {
    return FormSubmission(
      submissionId: submissionId ?? this.submissionId,
      formId: formId ?? this.formId,
      formTitle: formTitle ?? this.formTitle,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      mentorId: mentorId ?? this.mentorId,
      responses: responses ?? this.responses,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      mentorFeedback: mentorFeedback ?? this.mentorFeedback,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
