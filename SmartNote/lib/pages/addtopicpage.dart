import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/data/globaldata.dart';
import 'package:note_organiser/pages/uploadfile.dart';
import 'dart:io' as io; // For mobile

class AddTopicPage extends StatefulWidget {
  final String path;
  final bool canUpload;
  const AddTopicPage({super.key, required this.path, required this.canUpload});

  @override
  State<AddTopicPage> createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage> {
  // --- ORIGINAL LOGIC: Preserved as requested ---
  String link = '';
  final titleC = TextEditingController(), desC = TextEditingController();

  void addTopic() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during loading
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await FirebaseFirestore.instance.collection(widget.path).doc().set({
        'title': titleC.text.trim(),
        'description': desC.text.trim(),
        'author': globalEmail,
        'status': widget.canUpload ? 'accepted' : 'pending',
        'uploadDate': DateTime.now(),
        'link': link,
      });
      if (mounted) Navigator.pop(context); // Pop the loading dialog
    } catch (e) {
      if (mounted) Navigator.pop(context); // Pop the loading dialog on error
      // Optionally show an error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add topic: $e")));
    }

    if (mounted) Navigator.pop(context); // Pop the AddTopicPage
  }
  // --- END OF ORIGINAL LOGIC ---

  @override
  void dispose() {
    titleC.dispose();
    desC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to style the UI
    final theme = Theme.of(context);

    return Scaffold(
      // Use theme color for the background
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // The AppBar is now fully styled by the AppTheme
        title: const Text("Add Topic"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            shrinkWrap: true,
            children: [
              Card(
                // Use theme colors for the card
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Topic Details",
                        // Use text styles from the theme
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Title",
                        // Use text styles from the theme
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleC,
                        style: theme.textTheme.bodyLarge,
                        // Use the theme-aware decoration
                        decoration: _buildInputDecoration(
                          theme,
                          "Enter topic title",
                        ),
                      ),
                      if (link.isEmpty) ...[
                        const SizedBox(height: 20),
                        Text("Content", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: desC,
                          maxLines: null,
                          minLines: 6,
                          style: theme.textTheme.bodyLarge,
                          decoration: _buildInputDecoration(
                            theme,
                            "Enter topic content",
                          ),
                        ),
                      ],
                      if (link.isNotEmpty) ...[
                        Text("File", style: theme.textTheme.titleMedium),
                        Text(link, style: theme.textTheme.titleMedium),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              // Original logic for onPressed is preserved
                              onPressed: addTopic,
                              // The button is now fully styled by the AppTheme
                              child: const Text("Add Topic"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => FileUploaderPage(
                                          linkBack: (l) {
                                            link = l;
                                            setState(() {});
                                          },
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.image_outlined, size: 20),
                              label: const Text("File"),
                              // Style the outlined button with theme colors
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                                side: BorderSide(
                                  color: theme.primaryColor,
                                  width: 0.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create consistent TextField decorations
  InputDecoration _buildInputDecoration(ThemeData theme, String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
