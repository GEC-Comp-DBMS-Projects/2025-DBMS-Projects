import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mentorship_form_model.dart';
import '../../models/form_submission_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class FillFormScreen extends StatefulWidget {
  final String formId;
  final String mentorId;
  const FillFormScreen({Key? key, required this.formId, required this.mentorId})
      : super(key: key);

  @override
  State<FillFormScreen> createState() => _FillFormScreenState();
}

class _FillFormScreenState extends State<FillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _responses = {};
  bool _isSubmitting = false;

  Future<void> _submitForm(MentorshipForm form, String studentId,
      String studentName, String studentEmail) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    _formKey.currentState!.save();

    // Check if all required questions are answered
    for (var question in form.questions) {
      if (question.isRequired) {
        final response = _responses[question.id];
        if (response == null ||
            (response is String && response.trim().isEmpty) ||
            (response is List && response.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please answer: ${question.question}')),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final submission = FormSubmission(
        submissionId: DateTime.now().millisecondsSinceEpoch.toString(),
        formId: widget.formId,
        formTitle: form.title,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        mentorId: widget.mentorId,
        responses: _responses,
        status: 'pending',
        submittedAt: DateTime.now(),
      );

      await FirestoreService().submitForm(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = authProvider.user?.uid ?? '';
    final studentName = authProvider.user?.name ?? 'Student';
    final studentEmail = authProvider.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill Application Form'),
      ),
      body: FutureBuilder<MentorshipForm?>(
        future: FirestoreService().getForm(widget.formId),
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

          final form = snapshot.data;
          if (form == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Form not found'),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  form.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  form.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(form.category),
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                          '${form.questions.length} questions'),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Questions
                        ...form.questions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final question = entry.value;
                          return _QuestionWidget(
                            key: ValueKey(question.id),
                            question: question,
                            index: index,
                            onSaved: (value) {
                              _responses[question.id] = value;
                            },
                            initialValue: _responses[question.id],
                          );
                        }).toList(),

                        const SizedBox(height: 80), // Space for submit button
                      ],
                    ),
                  ),
                ),

                // Submit Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text:
                        _isSubmitting ? 'Submitting...' : 'Submit Application',
                    onPressed: () =>
                        _submitForm(form, studentId, studentName, studentEmail),
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuestionWidget extends StatefulWidget {
  final FormQuestion question;
  final int index;
  final Function(dynamic) onSaved;
  final dynamic initialValue;

  const _QuestionWidget({
    Key? key,
    required this.question,
    required this.index,
    required this.onSaved,
    this.initialValue,
  }) : super(key: key);

  @override
  State<_QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<_QuestionWidget> {
  dynamic _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${widget.index + 1}. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (widget.question.isRequired)
                  const Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    switch (widget.question.type) {
      case 'text':
        return TextFormField(
          decoration: const InputDecoration(
            hintText: 'Enter your answer',
            border: OutlineInputBorder(),
          ),
          maxLines: 1,
          validator: (value) {
            if (widget.question.isRequired &&
                (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onSaved: (value) => widget.onSaved(value?.trim() ?? ''),
          initialValue: _currentValue as String?,
        );

      case 'textarea':
        return TextFormField(
          decoration: const InputDecoration(
            hintText: 'Enter your answer',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (widget.question.isRequired &&
                (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onSaved: (value) => widget.onSaved(value?.trim() ?? ''),
          initialValue: _currentValue as String?,
        );

      case 'radio':
        return Column(
          children: (widget.question.options ?? []).map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _currentValue as String?,
              onChanged: (value) {
                setState(() => _currentValue = value);
                widget.onSaved(value);
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case 'checkbox':
        final selectedOptions = _currentValue as List<String>? ?? [];
        return Column(
          children: (widget.question.options ?? []).map((option) {
            final isSelected = selectedOptions.contains(option);
            return CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                  _currentValue = List<String>.from(selectedOptions);
                });
                widget.onSaved(_currentValue);
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case 'dropdown':
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text('Select an option'),
          value: _currentValue as String?,
          items: (widget.question.options ?? []).map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onSaved(value);
          },
          validator: (value) {
            if (widget.question.isRequired && value == null) {
              return 'Please select an option';
            }
            return null;
          },
        );

      default:
        return const Text('Unsupported question type');
    }
  }
}
