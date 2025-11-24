// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/data/globaldata.dart';

class CreateNewGroupPage extends StatefulWidget {
  final VoidCallback f;
  const CreateNewGroupPage({super.key, required this.f});

  @override
  State<CreateNewGroupPage> createState() => _CreateNewGroupPageState();
}

class _CreateNewGroupPageState extends State<CreateNewGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPublicGroup = true;
  bool _isLoading = false;
  String _selectedRole = 'Member (view & comment)';

  String getRole() {
    switch (_selectedRole) {
      case 'Member (view & comment)':
        return 'member';
      case 'Admin':
        return 'admin';
      case 'Moderator':
        return 'editor';
      case 'View Only':
        return 'viewer';
      default:
        return 'member';
    }
  }

  void _showFeedback(String message, bool isError) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? theme.colorScheme.onError : Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isError ? theme.colorScheme.onError : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? theme.colorScheme.error : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
      ),
    );
  }

  void createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      _showFeedback('Please enter a group name.', true);
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showFeedback('Please enter a description for the group.', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      var classDoc = FirebaseFirestore.instance.collection('classes').doc();
      await classDoc.set({
        "public": _isPublicGroup,
        'general role': getRole(),
        "name": _groupNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'admin': globalEmail,
        'participants': [
          {'email': globalEmail, 'role': 'admin'},
        ],
      });

      await FirebaseFirestore.instance.collection('users').doc(globalEmail).update({
        'classes': FieldValue.arrayUnion([classDoc.id]),
      });

      widget.f();
      _showFeedback('Group created successfully!', false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showFeedback('An error occurred. Please try again.', true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create New Class'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Card ---
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.asset(
                        "assets/book9.jpg",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.groups_rounded, color: theme.primaryColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New Learning Space', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('Build your community', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Input Fields ---
              _buildSectionTitle(context, 'Class Name', Icons.edit_outlined),
              const SizedBox(height: 12),
              TextField(
                controller: _groupNameController,
                style: theme.textTheme.bodyLarge,
                decoration: _buildInputDecoration(
                  context,
                  hint: 'e.g., Advanced Physics Study Group',
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionTitle(context, 'Description', Icons.description_outlined),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                decoration: _buildInputDecoration(
                  context,
                  hint: 'Share the purpose, topics covered, and any guidelines...',
                  icon: Icons.article_outlined,
                ),
              ),
              const SizedBox(height: 28),

              // --- Settings Card ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSectionTitle(context, 'Class Settings', Icons.settings_outlined, isSub: true),
                    const SizedBox(height: 24),
                    _buildSwitchRow(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Divider(height: 1, color: theme.dividerColor),
                    ),
                    _buildDropdown(context),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Action Buttons ---
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, {bool isSub = false}) {
    final theme = Theme.of(context);
    final textStyle = isSub ? theme.textTheme.titleMedium : theme.textTheme.titleSmall;
    
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.hintColor),
        const SizedBox(width: 8),
        Text(title, style: textStyle),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, {required String hint, required IconData icon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      prefixIcon: Icon(icon, color: theme.hintColor.withOpacity(0.7), size: 20),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.primaryColor, width: 0.5),
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isPublicGroup ? theme.primaryColor.withOpacity(0.1) : theme.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isPublicGroup ? Icons.public_rounded : Icons.lock_outline_rounded,
              color: _isPublicGroup ? theme.primaryColor : theme.hintColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Public Class', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Anyone can discover and join', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: _isPublicGroup,
            onChanged: (value) => setState(() => _isPublicGroup = value),
            activeColor: theme.primaryColor,
            activeTrackColor: theme.primaryColor.withOpacity(0.3),
            inactiveThumbColor: theme.hintColor,
            inactiveTrackColor: theme.dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Default Member Role', Icons.badge_outlined, isSub: true),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.hintColor, size: 24),
              style: theme.textTheme.bodyLarge,
              items: ['Admin', 'Moderator', 'Member (view & comment)', 'View Only']
                  .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _selectedRole = newValue);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: theme.dividerColor, width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: _isLoading ? null : createGroup,
            style: theme.elevatedButtonTheme.style,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.onPrimary),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Create Class'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}