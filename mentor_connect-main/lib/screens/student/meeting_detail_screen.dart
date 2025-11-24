import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mentorship_app/models/meeting_model.dart';
import 'package:mentorship_app/services/meeting_service.dart';
import 'package:mentorship_app/widgets/custom_button.dart';
import 'package:mentorship_app/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:mentorship_app/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailScreen extends StatefulWidget {
  final String meetingId;

  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
  });

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  final _meetingService = MeetingService();
  final _responseNoteController = TextEditingController();
  final _cancelReasonController = TextEditingController();

  bool _isLoading = false;
  DateTime? _newDateTime;

  @override
  void dispose() {
    _responseNoteController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveMeeting(Meeting meeting) async {
    await _showResponseDialog(
      title: 'Approve Meeting',
      content: 'Do you want to approve this meeting request?',
      hasNote: true,
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          await _meetingService.approveMeeting(
            meetingId: widget.meetingId,
            responseNote: _responseNoteController.text.trim().isEmpty
                ? null
                : _responseNoteController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meeting approved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to approve meeting: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _declineMeeting(Meeting meeting) async {
    await _showResponseDialog(
      title: 'Decline Meeting',
      content: 'Please provide a reason for declining this meeting:',
      hasNote: true,
      noteRequired: true,
      onConfirm: () async {
        if (_responseNoteController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide a reason'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() => _isLoading = true);
        try {
          await _meetingService.declineMeeting(
            meetingId: widget.meetingId,
            responseNote: _responseNoteController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meeting declined'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to decline meeting: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _postponeMeeting(Meeting meeting) async {
    final date = await showDatePicker(
      context: context,
      initialDate: meeting.dateTime.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(meeting.dateTime),
      );

      if (time != null && mounted) {
        _newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        await _showResponseDialog(
          title: 'Postpone Meeting',
          content:
              'Postpone to ${DateFormat('MMM dd, yyyy - hh:mm a').format(_newDateTime!)}?',
          hasNote: true,
          onConfirm: () async {
            setState(() => _isLoading = true);
            try {
              await _meetingService.postponeMeeting(
                meetingId: widget.meetingId,
                newDateTime: _newDateTime!,
                responseNote: _responseNoteController.text.trim().isEmpty
                    ? null
                    : _responseNoteController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meeting postponed'),
                    backgroundColor: Colors.purple,
                  ),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to postpone meeting: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
        );
      }
    }
  }

  Future<void> _cancelMeeting(Meeting meeting) async {
    await _showResponseDialog(
      title: 'Cancel Meeting',
      content: 'Please provide a reason for canceling this meeting:',
      hasNote: true,
      noteRequired: true,
      noteController: _cancelReasonController,
      onConfirm: () async {
        if (_cancelReasonController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide a cancellation reason'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() => _isLoading = true);
        try {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await _meetingService.cancelMeeting(
            meetingId: widget.meetingId,
            cancelReason: _cancelReasonController.text.trim(),
            cancelledBy: authProvider.user!.uid,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meeting cancelled'),
                backgroundColor: Colors.grey,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to cancel meeting: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _completeMeeting() async {
    setState(() => _isLoading = true);
    try {
      await _meetingService.completeMeeting(meetingId: widget.meetingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting marked as completed'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinOnlineMeeting(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch meeting link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showResponseDialog({
    required String title,
    required String content,
    bool hasNote = false,
    bool noteRequired = false,
    TextEditingController? noteController,
    required VoidCallback onConfirm,
  }) async {
    final controller = noteController ?? _responseNoteController;
    controller.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            if (hasNote) ...[
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: noteRequired ? 'Reason*' : 'Note (optional)',
                  border: const OutlineInputBorder(),
                  hintText: noteRequired
                      ? 'Please provide a reason'
                      : 'Add a note (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
      ),
      body: FutureBuilder<Meeting?>(
        future: _meetingService.getMeetingById(widget.meetingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final meeting = snapshot.data;
          if (meeting == null) {
            return const Center(child: Text('Meeting not found'));
          }

          final authProvider = Provider.of<AuthProvider>(context);
          final userId = authProvider.user?.uid ?? '';

          final isOrganizer = meeting.requestedBy == 'mentor'
              ? meeting.mentorId == userId
              : meeting.studentId == userId;

          final canRespond = meeting.isPending && !isOrganizer;
          final canCancel = (meeting.isPending ||
                  meeting.isAccepted ||
                  meeting.isPostponed) &&
              !meeting.isPast;
          final canComplete = (meeting.isAccepted || meeting.isPostponed) &&
              meeting.isPast &&
              !meeting.isCompleted;
          final canJoin = meeting.isOnline &&
              meeting.location.isNotEmpty &&
              (meeting.isAccepted || meeting.isPostponed) &&
              (meeting.isUpcoming || meeting.isOngoing);

          return _isLoading
              ? const LoadingWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      _buildStatusBadge(meeting),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        meeting.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildInfoCard(
                        icon: Icons.description,
                        title: 'Description',
                        content: meeting.description,
                      ),
                      const SizedBox(height: 16),

                      // Participants
                      _buildInfoCard(
                        icon: Icons.people,
                        title: 'Participants',
                        content:
                            '${meeting.mentorName} (Mentor) & ${meeting.studentName} (Student)',
                      ),
                      const SizedBox(height: 16),

                      // Date & Time
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: DateFormat('EEEE, MMMM dd, yyyy - hh:mm a')
                            .format(meeting.dateTime),
                        subtitle: meeting.originalDateTime != null
                            ? 'Originally: ${DateFormat('MMM dd, yyyy - hh:mm a').format(meeting.originalDateTime!)}'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      _buildInfoCard(
                        icon: Icons.timer,
                        title: 'Duration',
                        content: '${meeting.duration} minutes',
                      ),
                      const SizedBox(height: 16),

                      // Location
                      _buildInfoCard(
                        icon: meeting.isOnline
                            ? Icons.videocam
                            : Icons.location_on,
                        title: meeting.isOnline ? 'Meeting Link' : 'Location',
                        content: meeting.location.isEmpty
                            ? (meeting.isOnline
                                ? 'No link provided yet'
                                : 'No location provided')
                            : meeting.location,
                        trailing: meeting.location.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () =>
                                    _copyToClipboard(meeting.location),
                                tooltip: 'Copy to clipboard',
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Organizer Info
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Organized By',
                        content: meeting.requestedBy == 'mentor'
                            ? '${meeting.mentorName} (Mentor)'
                            : '${meeting.studentName} (Student)',
                      ),

                      // Response Note
                      if (meeting.responseNote != null &&
                          meeting.responseNote!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.comment,
                          title: 'Response Note',
                          content: meeting.responseNote!,
                        ),
                      ],

                      // Cancel Reason
                      if (meeting.cancelReason != null &&
                          meeting.cancelReason!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.info,
                          title: 'Cancellation Reason',
                          content: meeting.cancelReason!,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Action Buttons
                      if (canJoin) ...[
                        CustomButton(
                          text: 'Join Meeting',
                          onPressed: () => _joinOnlineMeeting(meeting.location),
                          icon: Icons.videocam,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (canRespond) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Approve',
                                onPressed: () => _approveMeeting(meeting),
                                backgroundColor: Colors.green,
                                icon: Icons.check,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Decline',
                                onPressed: () => _declineMeeting(meeting),
                                backgroundColor: Colors.red,
                                icon: Icons.close,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Postpone',
                          onPressed: () => _postponeMeeting(meeting),
                          backgroundColor: Colors.purple,
                          icon: Icons.update,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (canCancel) ...[
                        CustomButton(
                          text: 'Cancel Meeting',
                          onPressed: () => _cancelMeeting(meeting),
                          backgroundColor: Colors.grey,
                          icon: Icons.cancel,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (canComplete) ...[
                        CustomButton(
                          text: 'Mark as Completed',
                          onPressed: _completeMeeting,
                          backgroundColor: Colors.blue,
                          icon: Icons.done_all,
                        ),
                      ],
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildStatusBadge(Meeting meeting) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (meeting.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending Approval';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Accepted';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        statusText = 'Cancelled';
        break;
      case 'postponed':
        statusColor = Colors.purple;
        statusIcon = Icons.update;
        statusText = 'Postponed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = meeting.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
