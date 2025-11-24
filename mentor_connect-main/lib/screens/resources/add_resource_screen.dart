import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/resource_service.dart';
import '../../config/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddResourceScreen extends StatefulWidget {
  const AddResourceScreen({Key? key}) : super(key: key);

  @override
  State<AddResourceScreen> createState() => _AddResourceScreenState();
}

class _AddResourceScreenState extends State<AddResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResourceService _resourceService = ResourceService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedType = 'link';
  bool _isSharedWithAll = true;
  bool _isLoading = false;

  final List<String> _resourceTypes = [
    'link',
    'pdf',
    'doc',
    'video',
    'image',
    'other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitResource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add resources')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      await _resourceService.addResource(
        mentorId: currentUser.uid,
        mentorName: currentUser.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        link: _selectedType == 'link' ? _linkController.text.trim() : null,
        tags: tags,
        sharedWith: _isSharedWithAll
            ? null
            : [], // null = all, empty = none (will add students later)
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding resource: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Resource'),
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
                    // Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter resource title',
                      prefixIcon: Icons.title,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter resource description',
                      prefixIcon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Resource Type
                    Text(
                      'Resource Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _resourceTypes.map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Link input (only for link type)
                    if (_selectedType == 'link') ...[
                      CustomTextField(
                        controller: _linkController,
                        label: 'Resource Link',
                        hint: 'https://example.com/resource',
                        prefixIcon: Icons.link,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a link';
                          }
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'Please enter a valid URL (starting with http:// or https://)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // File upload placeholder for other types
                    if (_selectedType != 'link') ...[
                      Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_upload,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'File upload coming soon!',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'For now, upload your file to Google Drive or Dropbox\nand share the link using "Link" type above',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tags
                    CustomTextField(
                      controller: _tagsController,
                      label: 'Tags (optional)',
                      hint: 'programming, tutorial, beginner (comma separated)',
                      prefixIcon: Icons.local_offer,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Visibility
                    Text(
                      'Visibility',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<bool>(
                            title: const Text('All Students'),
                            subtitle:
                                const Text('Anyone can view this resource'),
                            value: true,
                            groupValue: _isSharedWithAll,
                            onChanged: (value) {
                              setState(() {
                                _isSharedWithAll = value!;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          const Divider(height: 1),
                          RadioListTile<bool>(
                            title: const Text('Accepted Students Only'),
                            subtitle: const Text(
                                'Only students whose applications you accepted'),
                            value: false,
                            groupValue: _isSharedWithAll,
                            onChanged: (value) {
                              setState(() {
                                _isSharedWithAll = value!;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      text: 'Add Resource',
                      onPressed: _submitResource,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
