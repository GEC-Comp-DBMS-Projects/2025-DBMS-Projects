import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String meetingId;
  final String mentorId;
  final String mentorName;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final DateTime dateTime;
  final int duration; // in minutes
  final String location; // physical location or meeting link
  final String meetingType; // 'online' or 'physical'
  final String
      status; // 'pending', 'accepted', 'declined', 'completed', 'cancelled', 'postponed'
  final String requestedBy; // 'mentor' or 'student'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseNote;
  final String? cancelReason;
  final DateTime? originalDateTime; // For postponed meetings
  final List<String> participants; // [mentorId, studentId]

  Meeting({
    required this.meetingId,
    required this.mentorId,
    required this.mentorName,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.duration,
    required this.location,
    this.meetingType = 'online',
    this.status = 'pending',
    required this.requestedBy,
    required this.createdAt,
    this.respondedAt,
    this.responseNote,
    this.cancelReason,
    this.originalDateTime,
    List<String>? participants,
  }) : participants = participants ?? [mentorId, studentId];

  Map<String, dynamic> toMap() {
    return {
      'meetingId': meetingId,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'location': location,
      'meetingType': meetingType,
      'status': status,
      'requestedBy': requestedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'responseNote': responseNote,
      'cancelReason': cancelReason,
      'originalDateTime': originalDateTime != null
          ? Timestamp.fromDate(originalDateTime!)
          : null,
      'participants': participants,
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      meetingId: map['meetingId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      duration: map['duration'] ?? 30,
      location: map['location'] ?? '',
      meetingType: map['meetingType'] ?? 'online',
      status: map['status'] ?? 'pending',
      requestedBy: map['requestedBy'] ?? 'mentor',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      responseNote: map['responseNote'],
      cancelReason: map['cancelReason'],
      originalDateTime: map['originalDateTime'] != null
          ? (map['originalDateTime'] as Timestamp).toDate()
          : null,
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Meeting copyWith({
    String? meetingId,
    String? mentorId,
    String? mentorName,
    String? studentId,
    String? studentName,
    String? title,
    String? description,
    DateTime? dateTime,
    int? duration,
    String? location,
    String? meetingType,
    String? status,
    String? requestedBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? responseNote,
    String? cancelReason,
    DateTime? originalDateTime,
    List<String>? participants,
  }) {
    return Meeting(
      meetingId: meetingId ?? this.meetingId,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      meetingType: meetingType ?? this.meetingType,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseNote: responseNote ?? this.responseNote,
      cancelReason: cancelReason ?? this.cancelReason,
      originalDateTime: originalDateTime ?? this.originalDateTime,
      participants: participants ?? this.participants,
    );
  }

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPostponed => status == 'postponed';

  // Time helpers
  bool get isPast =>
      DateTime.now().isAfter(dateTime.add(Duration(minutes: duration)));
  bool get isUpcoming => DateTime.now().isBefore(dateTime);
  bool get isOngoing =>
      DateTime.now().isAfter(dateTime) &&
      DateTime.now().isBefore(dateTime.add(Duration(minutes: duration)));

  // Meeting type helpers
  bool get isOnline => meetingType == 'online';
  bool get isPhysical => meetingType == 'physical';
}
