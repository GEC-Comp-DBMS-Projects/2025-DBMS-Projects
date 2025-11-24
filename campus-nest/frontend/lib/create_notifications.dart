import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../toast.dart'; 

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({Key? key}) : super(key: key);

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  List<dynamic> _allStudents = [];
  Set<String> _selectedStudentIds = {};
  bool _isLoadingStudents = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- API Logic ---
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchStudents() async {
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoadingStudents = false);
      return;
    }
    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/tpo/students');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 && mounted) {
        print("Students fetched: ${response.body}");
        setState(() {
          _allStudents = jsonDecode(response.body)['students'] ?? [];
          _isLoadingStudents = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingStudents = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, "Please fill all fields and select recipients.");
      return;
    }

    setState(() => _isSending = true);
    final token = await _getToken();
    final url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/tpo/notifications");

    final body = jsonEncode({
      "subject": _subjectController.text,
      "message": _messageController.text,
      "studentIds": _selectedStudentIds.toList(),
    });

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: body);
      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          AppToast.success(context, "Notification sent successfully!");
          Navigator.pop(context, true);
        } else {
          AppToast.error(context, "Failed to send: ${response.body}");
        }
      }
    } catch (e) {
      if (mounted) AppToast.error(context, "An error occurred: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedStudentIds.length == _allStudents.length) {
        _selectedStudentIds.clear();
      } else {
        _selectedStudentIds = _allStudents.map((s) => s['id'] as String).toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CustomPallete.lightTeal, CustomPallete.primaryColor, CustomPallete.darkColor],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(_subjectController, "Subject", Icons.title_rounded),
                        _buildTextField(_messageController, "Message", Icons.message_outlined, maxLines: 5),
                        const SizedBox(height: 24),
                        _buildStudentSelector(),
                        const SizedBox(height: 32),
                        _buildSendButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: lightColor),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Text('Send Notification', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: lightColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(color: darkColor, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(color: grayColor, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: grayColor.withOpacity(0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: grayColor.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
        ),
        validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildStudentSelector() {
    return FormField<Set<String>>(
      initialValue: _selectedStudentIds,
      validator: (value) => (value == null || value.isEmpty) ? 'Please select at least one student' : null,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: formFieldState.hasError ? Colors.red : primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Recipients", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: darkColor)),
                  const SizedBox(height: 8),
                  if (_isLoadingStudents)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                  else ...[
                    CheckboxListTile(
                      title: Text("Select All Students (${_allStudents.length})", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                      value: _selectedStudentIds.length == _allStudents.length && _allStudents.isNotEmpty,
                      onChanged: (value) => _toggleSelectAll(),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: primaryColor,
                    ),
                    const Divider(),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _allStudents.length,
                        itemBuilder: (context, index) {
                          final student = _allStudents[index];
                          final studentId = student['id'];
                          return CheckboxListTile(
                            title: Text("${student['firstName']} ${student['lastName']}", style: GoogleFonts.montserrat()),
                            subtitle: Text(student['department'] ?? 'No department', style: GoogleFonts.montserrat(fontSize: 12)),
                            value: _selectedStudentIds.contains(studentId),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedStudentIds.add(studentId);
                                } else {
                                  _selectedStudentIds.remove(studentId);
                                }
                                formFieldState.didChange(_selectedStudentIds);
                              });
                            },
                            activeColor: primaryColor,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(formFieldState.errorText!, style: GoogleFonts.montserrat(color: Colors.red.shade700, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildSendButton() {
    return ElevatedButton.icon(
      onPressed: _isSending ? null : _sendNotification,
      icon: _isSending ? Container(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, size: 18),
      label: Text(_isSending ? "Sending..." : "Send Notification"),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}