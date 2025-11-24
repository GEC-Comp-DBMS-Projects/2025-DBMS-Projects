import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorship_app/services/meeting_service.dart';
import 'package:mentorship_app/widgets/custom_button.dart';
import 'package:mentorship_app/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:mentorship_app/providers/auth_provider.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserRole; // 'mentor' or 'student'

  const ScheduleMeetingScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
  });

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final _meetingService = MeetingService();

  DateTime? _selectedDateTime;
  String _meetingType = 'online';
  int _duration = 30;
  bool _isLoading = false;

  final List<int> _durationOptions = [30, 60, 90, 120];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _scheduleMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user!;

      // Determine mentor and student IDs based on current user role
      final String mentorId, mentorName, studentId, studentName, requestedBy;

      if (currentUser.role == 'mentor') {
        mentorId = currentUser.uid;
        mentorName = currentUser.name;
        studentId = widget.otherUserId;
        studentName = widget.otherUserName;
        requestedBy = 'mentor';
      } else {
        studentId = currentUser.uid;
        studentName = currentUser.name;
        mentorId = widget.otherUserId;
        mentorName = widget.otherUserName;
        requestedBy = 'student';
      }

      await _meetingService.createMeeting(
        mentorId: mentorId,
        mentorName: mentorName,
        studentId: studentId,
        studentName: studentName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime!,
        duration: _duration,
        location: _locationController.text.trim(),
        meetingType: _meetingType,
        requestedBy: requestedBy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              requestedBy == 'mentor'
                  ? 'Meeting request sent to $studentName'
                  : 'Meeting request sent to $mentorName',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user!;
    final isRequestingMeeting = currentUser.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isRequestingMeeting ? 'Request Meeting' : 'Schedule Meeting'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isRequestingMeeting
                                    ? 'Send a meeting request to ${widget.otherUserName}. They will be notified and can approve or decline.'
                                    : 'Schedule a meeting with ${widget.otherUserName}. They will be notified and can approve or decline.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meeting Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Meeting Title',
                      hint: 'e.g., Career Guidance Session',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a meeting title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'What will you discuss?',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Meeting Type
                    const Text(
                      'Meeting Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Online'),
                            subtitle: const Text('Video call'),
                            value: 'online',
                            groupValue: _meetingType,
                            onChanged: (value) {
                              setState(() {
                                _meetingType = value!;
                                _locationController.clear();
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Physical'),
                            subtitle: const Text('In person'),
                            value: 'physical',
                            groupValue: _meetingType,
                            onChanged: (value) {
                              setState(() {
                                _meetingType = value!;
                                _locationController.clear();
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location / Meeting Link
                    CustomTextField(
                      controller: _locationController,
                      label: _meetingType == 'online'
                          ? 'Meeting Link (optional)'
                          : 'Physical Location',
                      hint: _meetingType == 'online'
                          ? 'e.g., https://meet.google.com/xxx'
                          : 'e.g., Campus Library, Room 301',
                      prefixIcon: _meetingType == 'online'
                          ? Icons.link
                          : Icons.location_on,
                      validator: _meetingType == 'physical'
                          ? (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the meeting location';
                              }
                              return null;
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Date and Time
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.blue),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDateTime == null
                                  ? 'Select date and time'
                                  : DateFormat('MMM dd, yyyy - hh:mm a')
                                      .format(_selectedDateTime!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDateTime == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _durationOptions.map((minutes) {
                        final isSelected = _duration == minutes;
                        return ChoiceChip(
                          label: Text('$minutes min'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _duration = minutes);
                            }
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    CustomButton(
                      text: isRequestingMeeting
                          ? 'Send Request'
                          : 'Schedule Meeting',
                      onPressed: _scheduleMeeting,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
