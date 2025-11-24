import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/mentorship_form_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateFormScreen extends StatefulWidget {
  final String? formId;
  const CreateFormScreen({Key? key, this.formId}) : super(key: key);

  @override
  State<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General';
  final List<String> _categories = [
    'General',
    'Academic',
    'Career',
    'Project',
    'Technical',
    'Personal Development',
  ];

  final List<FormQuestion> _questions = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.formId != null) {
      _isEditing = true;
      _loadExistingForm();
    } else {
      // Add a default question
      _addQuestion();
    }
  }

  Future<void> _loadExistingForm() async {
    // TODO: Load existing form for editing
    // For now, just add a default question
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        FormQuestion(
          id: const Uuid().v4(),
          question: '',
          type: 'text',
          isRequired: true,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form must have at least one question')),
      );
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate questions
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question')),
      );
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].question.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} cannot be empty')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw 'User not found';
      }

      final form = MentorshipForm(
        formId: widget.formId ?? const Uuid().v4(),
        mentorId: user.uid,
        mentorName: user.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: _questions,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await FirestoreService().createForm(form);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Form updated successfully'
              : 'Form created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Form' : 'Create Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
            tooltip: 'Save Form',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Form Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Form Title',
                    hint: 'e.g., "Software Engineering Mentorship Application"',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a form title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe what this form is for...',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Questions Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Questions List
                  ...List.generate(_questions.length, (index) {
                    return _QuestionCard(
                      key: ValueKey(_questions[index].id),
                      question: _questions[index],
                      index: index,
                      onUpdate: (updatedQuestion) {
                        setState(() {
                          _questions[index] = updatedQuestion;
                        });
                      },
                      onRemove: () => _removeQuestion(index),
                      canRemove: _questions.length > 1,
                    );
                  }),

                  const SizedBox(height: 24),

                  // Save Button
                  CustomButton(
                    text: _isEditing ? 'Update Form' : 'Create Form',
                    onPressed: _saveForm,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final FormQuestion question;
  final int index;
  final Function(FormQuestion) onUpdate;
  final VoidCallback onRemove;
  final bool canRemove;

  const _QuestionCard({
    Key? key,
    required this.question,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.canRemove,
  }) : super(key: key);

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _questionController;
  late String _selectedType;
  late bool _isRequired;
  late List<String> _options;
  late List<TextEditingController> _optionControllers;

  final List<String> _questionTypes = [
    'text',
    'textarea',
    'radio',
    'checkbox',
    'dropdown',
  ];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.question);
    _selectedType = widget.question.type;
    _isRequired = widget.question.isRequired;
    _options = widget.question.options ?? [];
    _optionControllers =
        _options.map((opt) => TextEditingController(text: opt)).toList();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    widget.onUpdate(
      FormQuestion(
        id: widget.question.id,
        question: _questionController.text,
        type: _selectedType,
        options: _needsOptions ? _options : null,
        isRequired: _isRequired,
      ),
    );
  }

  bool get _needsOptions =>
      _selectedType == 'radio' ||
      _selectedType == 'checkbox' ||
      _selectedType == 'dropdown';

  void _addOption() {
    setState(() {
      _options.add('');
      _optionControllers.add(TextEditingController(text: ''));
    });
    _updateQuestion();
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _options.removeAt(index);
    });
    _updateQuestion();
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
            // Question Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Question ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: widget.onRemove,
                    tooltip: 'Remove Question',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Text
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Question Text',
                hintText: 'Enter your question here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _updateQuestion(),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Question Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Answer Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _questionTypes.map((type) {
                String displayName;
                IconData icon;

                switch (type) {
                  case 'text':
                    displayName = 'Short Text';
                    icon = Icons.short_text;
                    break;
                  case 'textarea':
                    displayName = 'Long Text';
                    icon = Icons.subject;
                    break;
                  case 'radio':
                    displayName = 'Multiple Choice';
                    icon = Icons.radio_button_checked;
                    break;
                  case 'checkbox':
                    displayName = 'Checkboxes';
                    icon = Icons.check_box;
                    break;
                  case 'dropdown':
                    displayName = 'Dropdown';
                    icon = Icons.arrow_drop_down_circle;
                    break;
                  default:
                    displayName = type;
                    icon = Icons.help;
                }

                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    if (_needsOptions && _options.isEmpty) {
                      _options = ['Option 1', 'Option 2'];
                      _optionControllers = _options
                          .map((opt) => TextEditingController(text: opt))
                          .toList();
                    }
                  });
                  _updateQuestion();
                }
              },
            ),

            // Options (for radio, checkbox, dropdown)
            if (_needsOptions) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Options',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Option'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_options.length, (optionIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[optionIndex],
                          decoration: InputDecoration(
                            labelText: 'Option ${optionIndex + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            _options[optionIndex] = value;
                            _updateQuestion();
                          },
                        ),
                      ),
                      if (_options.length > 2)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => _removeOption(optionIndex),
                        ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 12),

            // Required Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value ?? true;
                    });
                    _updateQuestion();
                  },
                ),
                const Text('Required question'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
