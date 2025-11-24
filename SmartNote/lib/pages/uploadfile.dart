import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FileUploaderPage extends StatefulWidget {
  final Function(String) linkBack;
  const FileUploaderPage({super.key,required this.linkBack});

  @override
  _FileUploaderPageState createState() => _FileUploaderPageState();
}

class _FileUploaderPageState extends State<FileUploaderPage> {
  // --- ORIGINAL LOGIC: Preserved as requested ---
  bool _loading = false;
  String _message = '';
Future<void> pickAndUploadFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    withData: false, // <- IMPORTANT: don't load bytes into memory
  );

  if (result == null) {
    setState(() => _message = "No file selected");
    return;
  }

  setState(() {
    _loading = true;
    _message = '';
  });

  try {
    final pickedFile = result.files.first;
    final fileName = pickedFile.name;

    final uri = Uri.parse('https://note-organizer-backend2.onrender.com/upload_file');
    final request = http.MultipartRequest('POST', uri);

    if (pickedFile.path != null) {
      // Use path for mobile/desktop
      request.files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path!, filename: fileName),
      );
    } else if (pickedFile.bytes != null) {
      // Use bytes for web
      request.files.add(
        http.MultipartFile.fromBytes('file', pickedFile.bytes!, filename: fileName),
      );
    } else {
      throw Exception("File data is missing");
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final respJson = jsonDecode(respStr);

    if (response.statusCode == 200 && respJson['success'] == true) {
      setState(() => _message = "Success: ${respJson['file_url']}");
      widget.linkBack(respJson['file_url']);
    } else {
      setState(() => _message = "Failed: ${respJson['error'] ?? respStr}");
    }
  } catch (e) {
    setState(() => _message = "Error: $e");
  } finally {
    setState(() => _loading = false);
  }
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
        title: const Text('Upload Image/PDF'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            // Use theme colors for the card
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor, width: 1.5),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      // Use theme color for the icon background
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      // Use theme color for the icon
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload File',
                    // Use text styles from the theme
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an image or PDF file to upload',
                    // Use text styles from the theme
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // Original logic for onPressed is preserved
                      onPressed: _loading ? null : pickAndUploadFile,
                      // The button is now fully styled by the AppTheme
                      icon: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                // Use theme color for the loading indicator
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.file_upload_outlined, size: 20),
                      label: Text(
                        _loading ? 'Uploading...' : 'Pick & Upload File',
                      ),
                    ),
                  ),
                  // The message display widget is preserved
                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildMessageDisplay(context, _message),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to display feedback messages using theme colors
  Widget _buildMessageDisplay(BuildContext context, String message) {
    final theme = Theme.of(context);

    // Determine color and icon based on message content
    Color color;
    IconData icon;

    if (message.toLowerCase().contains('success')) {
      color = Colors.green.shade600;
      icon = Icons.check_circle_outline;
    } else if (message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('failed')) {
      color = theme.colorScheme.error;
      icon = Icons.error_outline;
    } else {
      color = theme.primaryColor;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}