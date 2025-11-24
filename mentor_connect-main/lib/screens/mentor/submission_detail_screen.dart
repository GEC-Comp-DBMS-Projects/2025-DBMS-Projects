import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/form_submission_model.dart';
import '../../models/mentorship_form_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/mentorship_service.dart';
import '../../services/notification_helper.dart';
import '../../services/file_download_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class SubmissionDetailScreen extends StatefulWidget {
  final String submissionId;
  const SubmissionDetailScreen({Key? key, required this.submissionId})
      : super(key: key);

  @override
  State<SubmissionDetailScreen> createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  final _feedbackController = TextEditingController();
  bool _isUpdating = false;
  bool _isDownloading = false;
  FormSubmission? _submission;
  Map<String, String> _questionMap = {}; // questionId -> question text
  late Future<FormSubmission?> _submissionFuture;

  @override
  void initState() {
    super.initState();
    _submissionFuture = _getSubmission();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'reviewed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'reviewed':
        return Icons.rate_review;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateSubmissionStatus(String status) async {
    if (_feedbackController.text.trim().isEmpty &&
        (status == 'accepted' || status == 'rejected')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please provide feedback before ${status == 'accepted' ? 'accepting' : 'rejecting'}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${status == 'accepted' ? 'Accept' : status == 'rejected' ? 'Reject' : 'Review'} Submission?'),
        content: Text(
          status == 'accepted'
              ? 'Are you sure you want to accept this submission? The student will be notified and added as your mentee.'
              : status == 'rejected'
                  ? 'Are you sure you want to reject this submission? The student will be notified.'
                  : 'Mark this submission as reviewed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(status),
            ),
            child: Text(status == 'accepted'
                ? 'Accept'
                : status == 'rejected'
                    ? 'Reject'
                    : 'Mark Reviewed'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);

    try {
      // Update submission status
      await FirestoreService().updateSubmission(
        widget.submissionId,
        {
          'status': status,
          'mentorFeedback': _feedbackController.text.trim(),
          'reviewedAt': DateTime.now(),
        },
      );

      // If accepted, create mentorship relationship
      if (status == 'accepted' && _submission != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final mentor = userProvider.currentUser;

        if (mentor != null) {
          await MentorshipService().createMentorship(_submission!, mentor);
        }
      }

      // Send notification to student about status change
      if (_submission != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final mentor = userProvider.currentUser;

        if (mentor != null) {
          await NotificationHelper.sendFormStatusNotification(
            studentId: _submission!.studentId,
            mentorName: mentor.name,
            status: status,
            formTitle: _submission!.formTitle,
            submissionId: widget.submissionId,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Submission ${status == 'accepted' ? 'accepted' : status == 'rejected' ? 'rejected' : 'marked as reviewed'}!${status == 'accepted' ? ' Student added to your mentees.' : ''}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<FormSubmission?> _getSubmission() async {
    // Get submission directly by ID from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('form_submissions')
        .doc(widget.submissionId)
        .get();

    if (!doc.exists) {
      throw Exception('Submission not found');
    }

    final submission = FormSubmission.fromMap(doc.data()!);

    // Fetch the form to get question texts
    await _loadFormQuestions(submission.formId);

    return submission;
  }

  Future<void> _loadFormQuestions(String formId) async {
    try {
      final formDoc = await FirebaseFirestore.instance
          .collection('mentorship_forms')
          .doc(formId)
          .get();

      if (formDoc.exists) {
        final form = MentorshipForm.fromMap(formDoc.data()!);
        // Don't call setState here - just update the map
        _questionMap = {for (var q in form.questions) q.id: q.question};
      }
    } catch (e) {
      print('Error loading form questions: $e');
    }
  }

  Future<void> _downloadSubmission(
      FormSubmission submission, String format) async {
    setState(() => _isDownloading = true);

    try {
      String filePath;

      if (format == 'csv') {
        filePath = await FileDownloadService.downloadSubmissionAsCSV(
          submission,
          _questionMap,
        );
      } else {
        filePath = await FileDownloadService.downloadSubmissionAsTXT(
          submission,
          _questionMap,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Downloaded successfully!\nSaved to: ${filePath.split('/').last}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error downloading: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showDownloadOptions(FormSubmission submission) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Download Submission',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose file format',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              title: const Text(
                'CSV Format',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle:
                  const Text('Spreadsheet compatible (Excel, Google Sheets)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _downloadSubmission(submission, 'csv');
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description, color: Colors.blue),
              ),
              title: const Text(
                'Text Format',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Simple text file (easy to read)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _downloadSubmission(submission, 'txt');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(String questionId, dynamic answer) {
    // Get the actual question text from the map, fallback to questionId if not found
    final questionText = _questionMap[questionId] ?? questionId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    questionText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                answer is List ? answer.join(', ') : answer.toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.shade900,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Details'),
        elevation: 0,
        actions: [
          if (_submission != null)
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              onPressed: _isDownloading
                  ? null
                  : () => _showDownloadOptions(_submission!),
              tooltip: 'Download Submission',
            ),
        ],
      ),
      body: FutureBuilder<FormSubmission?>(
        future: _submissionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final submission = snapshot.data;
          if (submission == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Submission not found'),
                ],
              ),
            );
          }

          // Set initial feedback if exists
          if (_submission == null && submission.mentorFeedback != null) {
            _feedbackController.text = submission.mentorFeedback!;
            _submission = submission;
          }

          return Column(
            children: [
              // Header with status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        submission.studentName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      submission.studentName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.studentEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(submission.status).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(submission.status),
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            submission.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Form and date info
                    _buildInfoCard(
                      Icons.description,
                      'Form Title',
                      submission.formTitle,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.calendar_today,
                      'Submitted On',
                      _formatDate(submission.submittedAt),
                    ),
                    if (submission.reviewedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        Icons.rate_review,
                        'Reviewed On',
                        _formatDate(submission.reviewedAt!),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text(
                      'Student Responses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display all responses
                    ...submission.responses.entries
                        .map((e) => _buildResponseCard(e.key, e.value))
                        .toList(),

                    const SizedBox(height: 16),

                    // Download button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.purple.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isDownloading
                              ? null
                              : () => _showDownloadOptions(submission),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isDownloading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _isDownloading
                                      ? 'Downloading...'
                                      : 'Download Submission',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Mentor Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Feedback textarea
                    TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Provide your feedback to the student...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    if (submission.status.toLowerCase() == 'pending' ||
                        submission.status.toLowerCase() == 'reviewed') ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Reject',
                              onPressed: () =>
                                  _updateSubmissionStatus('rejected'),
                              backgroundColor: Colors.red,
                              icon: Icons.cancel,
                              isLoading: _isUpdating,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Accept',
                              onPressed: () =>
                                  _updateSubmissionStatus('accepted'),
                              icon: Icons.check_circle,
                              isLoading: _isUpdating,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Mark as Reviewed',
                        onPressed: () => _updateSubmissionStatus('reviewed'),
                        backgroundColor: Colors.blue,
                        icon: Icons.rate_review,
                        isLoading: _isUpdating,
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(submission.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(submission.status),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(submission.status),
                              color: _getStatusColor(submission.status),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This submission has been ${submission.status}',
                                style: TextStyle(
                                  color: _getStatusColor(submission.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
