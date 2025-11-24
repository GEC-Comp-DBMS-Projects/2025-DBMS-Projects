import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resource_model.dart';
import '../services/mentorship_service.dart';
import '../services/notification_helper.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MentorshipService _mentorshipService = MentorshipService();

  // Get all resources for a specific mentor
  Stream<List<Resource>> getMentorResources(String mentorId) {
    return _firestore
        .collection('resources')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList());
  }

  // Get resources available to a student
  // Shows resources from accepted mentors only
  Stream<List<Resource>> getStudentResources(
      String studentId, List<String> acceptedMentorIds) {
    if (acceptedMentorIds.isEmpty) {
      // Return empty stream if student has no accepted mentors
      return Stream.value([]);
    }

    return _firestore
        .collection('resources')
        .where('mentorId', whereIn: acceptedMentorIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final resource = Resource.fromMap(doc.data());
            // Filter: show if shared with all OR specifically shared with this student
            if (resource.isSharedWithAll ||
                (resource.sharedWith != null &&
                    resource.sharedWith!.contains(studentId))) {
              return resource;
            }
            return null;
          })
          .whereType<Resource>()
          .toList();
    });
  }

  // Add new resource
  Future<String> addResource({
    required String mentorId,
    required String mentorName,
    required String title,
    required String description,
    required String type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? link,
    List<String> tags = const [],
    List<String>? sharedWith, // null = shared with all
  }) async {
    final resourceId = _firestore.collection('resources').doc().id;

    final resource = Resource(
      resourceId: resourceId,
      mentorId: mentorId,
      mentorName: mentorName,
      title: title,
      description: description,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      link: link,
      tags: tags,
      createdAt: DateTime.now(),
      downloadCount: 0,
      sharedWith: sharedWith,
    );

    await _firestore
        .collection('resources')
        .doc(resourceId)
        .set(resource.toMap());

    // Send notifications to students
    if (resource.isSharedWithAll) {
      // Get all accepted students for this mentor
      final studentIds =
          await _mentorshipService.getAcceptedStudentIds(mentorId);

      // Send notification to each student
      for (final studentId in studentIds) {
        await NotificationHelper.sendNewResourceNotification(
          studentId: studentId,
          mentorName: mentorName,
          resourceTitle: title,
          resourceId: resourceId,
        );
      }
    } else if (sharedWith != null && sharedWith.isNotEmpty) {
      // Send notification to specific students
      for (final studentId in sharedWith) {
        await NotificationHelper.sendNewResourceNotification(
          studentId: studentId,
          mentorName: mentorName,
          resourceTitle: title,
          resourceId: resourceId,
        );
      }
    }

    return resourceId;
  }

  // Update existing resource
  Future<void> updateResource(
      String resourceId, Map<String, dynamic> updates) async {
    await _firestore.collection('resources').doc(resourceId).update(updates);
  }

  // Delete resource
  Future<void> deleteResource(String resourceId) async {
    await _firestore.collection('resources').doc(resourceId).delete();
  }

  // Increment download count
  Future<void> incrementDownloadCount(String resourceId) async {
    await _firestore.collection('resources').doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  // Get single resource by ID
  Future<Resource?> getResource(String resourceId) async {
    final doc = await _firestore.collection('resources').doc(resourceId).get();
    if (doc.exists) {
      return Resource.fromMap(doc.data()!);
    }
    return null;
  }

  // Get resources by type
  Stream<List<Resource>> getResourcesByType(String mentorId, String type) {
    return _firestore
        .collection('resources')
        .where('mentorId', isEqualTo: mentorId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList());
  }

  // Search resources by title or description
  Stream<List<Resource>> searchResources(String mentorId, String query) {
    return getMentorResources(mentorId).map((resources) {
      final lowerQuery = query.toLowerCase();
      return resources.where((resource) {
        return resource.title.toLowerCase().contains(lowerQuery) ||
            resource.description.toLowerCase().contains(lowerQuery) ||
            resource.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    });
  }
}
