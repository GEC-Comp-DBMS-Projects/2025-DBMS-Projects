import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentorship_model.dart';
import '../models/form_submission_model.dart';
import 'package:uuid/uuid.dart';

/// Service to migrate old accepted submissions to mentorships
/// Use this ONE TIME to fix existing accepted submissions
class MentorshipMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Create mentorships for all accepted submissions that don't have one
  Future<MigrationResult> migrateAcceptedSubmissions() async {
    int created = 0;
    int skipped = 0;
    int errors = 0;
    List<String> errorMessages = [];

    try {
      // Get all accepted submissions
      final submissionsSnapshot = await _firestore
          .collection('form_submissions')
          .where('status', isEqualTo: 'accepted')
          .get();

      print('Found ${submissionsSnapshot.docs.length} accepted submissions');

      for (var doc in submissionsSnapshot.docs) {
        try {
          final submission = FormSubmission.fromMap(doc.data());

          // Check if mentorship already exists
          final existingMentorship = await _firestore
              .collection('mentorships')
              .where('mentorId', isEqualTo: submission.mentorId)
              .where('studentId', isEqualTo: submission.studentId)
              .where('formId', isEqualTo: submission.formId)
              .limit(1)
              .get();

          if (existingMentorship.docs.isNotEmpty) {
            print(
                'Mentorship already exists for ${submission.studentName} - ${submission.formTitle}');
            skipped++;
            continue;
          }

          // Get mentor details
          final mentorDoc = await _firestore
              .collection('users')
              .doc(submission.mentorId)
              .get();

          if (!mentorDoc.exists) {
            print('Mentor not found for submission ${doc.id}');
            errors++;
            errorMessages.add('Mentor not found for ${submission.studentName}');
            continue;
          }

          final mentorData = mentorDoc.data()!;
          final mentorName = mentorData['name'] ?? 'Unknown Mentor';
          final mentorEmail = mentorData['email'] ?? '';

          // Create mentorship
          final mentorshipId = _uuid.v4();
          final mentorship = Mentorship(
            mentorshipId: mentorshipId,
            mentorId: submission.mentorId,
            mentorName: mentorName,
            mentorEmail: mentorEmail,
            studentId: submission.studentId,
            studentName: submission.studentName,
            studentEmail: submission.studentEmail,
            formId: submission.formId,
            formTitle: submission.formTitle,
            acceptedAt: submission.submittedAt, // Use original submission date
            status: 'active',
          );

          await _firestore
              .collection('mentorships')
              .doc(mentorshipId)
              .set(mentorship.toMap());

          print(
              'Created mentorship for ${submission.studentName} - ${submission.formTitle}');
          created++;
        } catch (e) {
          print('Error processing submission ${doc.id}: $e');
          errors++;
          errorMessages.add('Error: $e');
        }
      }

      return MigrationResult(
        created: created,
        skipped: skipped,
        errors: errors,
        errorMessages: errorMessages,
      );
    } catch (e) {
      print('Migration failed: $e');
      return MigrationResult(
        created: created,
        skipped: skipped,
        errors: errors + 1,
        errorMessages: [...errorMessages, 'Migration failed: $e'],
      );
    }
  }

  /// Delete all mentorships (use with caution - for testing only)
  Future<int> deleteAllMentorships() async {
    final snapshot = await _firestore.collection('mentorships').get();
    int deleted = 0;

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
      deleted++;
    }

    return deleted;
  }
}

class MigrationResult {
  final int created;
  final int skipped;
  final int errors;
  final List<String> errorMessages;

  MigrationResult({
    required this.created,
    required this.skipped,
    required this.errors,
    required this.errorMessages,
  });

  bool get isSuccess => errors == 0 && created > 0;
  bool get hasChanges => created > 0;

  @override
  String toString() {
    return 'Created: $created, Skipped: $skipped, Errors: $errors';
  }
}
