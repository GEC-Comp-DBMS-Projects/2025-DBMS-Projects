import 'package:cloud_firestore/cloud_firestore.dart';

class FormQuestion {
  final String id;
  final String question;
  final String type; // 'text', 'textarea', 'radio', 'checkbox', 'dropdown'
  final List<String>? options; // For radio, checkbox, dropdown
  final bool isRequired;

  FormQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.isRequired = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'isRequired': isRequired,
    };
  }

  factory FormQuestion.fromMap(Map<String, dynamic> map) {
    return FormQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      type: map['type'] ?? 'text',
      options:
          map['options'] != null ? List<String>.from(map['options']) : null,
      isRequired: map['isRequired'] ?? true,
    );
  }
}

class MentorshipForm {
  final String formId;
  final String mentorId;
  final String mentorName;
  final String title;
  final String description;
  final List<FormQuestion> questions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String category; // e.g., 'Academic', 'Career', 'Project', 'General'

  MentorshipForm({
    required this.formId,
    required this.mentorId,
    required this.mentorName,
    required this.title,
    required this.description,
    required this.questions,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.category = 'General',
  });

  Map<String, dynamic> toMap() {
    return {
      'formId': formId,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'category': category,
    };
  }

  factory MentorshipForm.fromMap(Map<String, dynamic> map) {
    return MentorshipForm(
      formId: map['formId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions: (map['questions'] as List<dynamic>)
          .map((q) => FormQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      category: map['category'] ?? 'General',
    );
  }

  MentorshipForm copyWith({
    String? formId,
    String? mentorId,
    String? mentorName,
    String? title,
    String? description,
    List<FormQuestion>? questions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
  }) {
    return MentorshipForm(
      formId: formId ?? this.formId,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }
}
