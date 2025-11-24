import 'package:cloud_firestore/cloud_firestore.dart';

class Resource {
  final String resourceId;
  final String mentorId;
  final String mentorName;
  final String title;
  final String description;
  final String type; // 'pdf', 'doc', 'link', 'video', 'image', 'other'
  final String? fileUrl;
  final String? fileName;
  final int? fileSize; // in bytes
  final String? link;
  final List<String> tags;
  final DateTime createdAt;
  final int downloadCount;
  final List<String>? sharedWith; // student IDs, null means shared with all

  Resource({
    required this.resourceId,
    required this.mentorId,
    required this.mentorName,
    required this.title,
    required this.description,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.link,
    this.tags = const [],
    required this.createdAt,
    this.downloadCount = 0,
    this.sharedWith,
  });

  Map<String, dynamic> toMap() {
    return {
      'resourceId': resourceId,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'title': title,
      'description': description,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'link': link,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'downloadCount': downloadCount,
      'sharedWith': sharedWith,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      resourceId: map['resourceId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'other',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      link: map['link'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      downloadCount: map['downloadCount'] ?? 0,
      sharedWith: map['sharedWith'] != null
          ? List<String>.from(map['sharedWith'])
          : null,
    );
  }

  Resource copyWith({
    String? resourceId,
    String? mentorId,
    String? mentorName,
    String? title,
    String? description,
    String? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? link,
    List<String>? tags,
    DateTime? createdAt,
    int? downloadCount,
    List<String>? sharedWith,
  }) {
    return Resource(
      resourceId: resourceId ?? this.resourceId,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      link: link ?? this.link,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      downloadCount: downloadCount ?? this.downloadCount,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  bool get isFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get isLink => link != null && link!.isNotEmpty;
  bool get isSharedWithAll => sharedWith == null;
}
