import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/form_submission_model.dart';

class FileDownloadService {
  /// Download submission as CSV file
  static Future<String> downloadSubmissionAsCSV(
    FormSubmission submission,
    Map<String, String> questionMap,
  ) async {
    try {
      // Prepare CSV data
      List<List<dynamic>> rows = [];

      // Header information
      rows.add(['Submission Details']);
      rows.add(['Student Name', submission.studentName]);
      rows.add(['Student Email', submission.studentEmail]);
      rows.add(['Form Title', submission.formTitle]);
      rows.add(['Status', submission.status]);
      rows.add([
        'Submitted At',
        _formatDateTime(submission.submittedAt),
      ]);
      if (submission.reviewedAt != null) {
        rows.add([
          'Reviewed At',
          _formatDateTime(submission.reviewedAt!),
        ]);
      }
      if (submission.mentorFeedback != null &&
          submission.mentorFeedback!.isNotEmpty) {
        rows.add(['Mentor Feedback', submission.mentorFeedback]);
      }

      rows.add([]); // Empty row
      rows.add(['Questions and Responses']);
      rows.add(['Question', 'Answer']); // Table header

      // Add all responses
      submission.responses.forEach((questionId, answer) {
        final questionText = questionMap[questionId] ?? questionId;
        final answerText =
            answer is List ? answer.join(', ') : answer.toString();
        rows.add([questionText, answerText]);
      });

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Get the directory to save the file
      // Use app-specific directory - no permission needed
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create a "Downloads" subfolder in app directory
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final studentNameClean = submission.studentName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      final filename = 'submission_${studentNameClean}_$timestamp.csv';

      // Create file and write CSV data
      final file = File('${downloadDir.path}/$filename');
      await file.writeAsString(csv);

      print('📥 File saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error downloading submission: $e');
      rethrow;
    }
  }

  /// Download submission as TXT file (simpler alternative)
  static Future<String> downloadSubmissionAsTXT(
    FormSubmission submission,
    Map<String, String> questionMap,
  ) async {
    try {
      // Prepare text content
      StringBuffer content = StringBuffer();

      // Header
      content.writeln('=' * 50);
      content.writeln('FORM SUBMISSION DETAILS');
      content.writeln('=' * 50);
      content.writeln();

      // Basic info
      content.writeln('Student Name: ${submission.studentName}');
      content.writeln('Student Email: ${submission.studentEmail}');
      content.writeln('Form Title: ${submission.formTitle}');
      content.writeln('Status: ${submission.status.toUpperCase()}');
      content
          .writeln('Submitted At: ${_formatDateTime(submission.submittedAt)}');

      if (submission.reviewedAt != null) {
        content
            .writeln('Reviewed At: ${_formatDateTime(submission.reviewedAt!)}');
      }

      if (submission.mentorFeedback != null &&
          submission.mentorFeedback!.isNotEmpty) {
        content.writeln();
        content.writeln('Mentor Feedback:');
        content.writeln(submission.mentorFeedback);
      }

      content.writeln();
      content.writeln('=' * 50);
      content.writeln('STUDENT RESPONSES');
      content.writeln('=' * 50);
      content.writeln();

      // Add all responses
      int questionNumber = 1;
      submission.responses.forEach((questionId, answer) {
        final questionText = questionMap[questionId] ?? questionId;
        final answerText =
            answer is List ? answer.join(', ') : answer.toString();

        content.writeln('Q$questionNumber: $questionText');
        content.writeln('A: $answerText');
        content.writeln();
        questionNumber++;
      });

      content.writeln('=' * 50);
      content.writeln('End of Submission');
      content.writeln('=' * 50);

      // Get the directory to save the file
      // Use app-specific directory - no permission needed
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create a "Downloads" subfolder in app directory
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Create filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final studentNameClean = submission.studentName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      final filename = 'submission_${studentNameClean}_$timestamp.txt';

      // Create file and write content
      final file = File('${downloadDir.path}/$filename');
      await file.writeAsString(content.toString());

      print('📥 File saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error downloading submission: $e');
      rethrow;
    }
  }

  /// Format DateTime to readable string
  static String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
