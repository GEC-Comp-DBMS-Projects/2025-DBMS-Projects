import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillconnect/cloudinary_service.dart';

class WorkerEditProfilePage extends StatefulWidget {
  const WorkerEditProfilePage({super.key});

  @override
  WorkerEditProfilePageState createState() => WorkerEditProfilePageState();
}

class WorkerEditProfilePageState extends State<WorkerEditProfilePage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color paleBlue = Color(0xFFA7CCED);

  // --- Form & State ---
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  Uint8List? _imageBytes;
  String? _currentProfilePicUrl;

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        final userData = userDoc.data()!;
        _nameController.text = userData['name'] ?? '';
        _contactController.text = userData['contact'] ?? '';
        _currentProfilePicUrl = userData['profilePicUrl'];
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load data: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) return;

    Uint8List fileBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name;

    setState(() {
      _isLoading = true;
      _imageBytes = fileBytes;
    });

    try {
      final String imageResourceType = "image";

      var response = await CloudinaryService.uploadFile(
        fileBytes,
        fileName,
        resourceType: imageResourceType,
      );

      if (response.statusCode == 200) {
        String imageUrl = response.data["secure_url"];

        setState(() {
          _currentProfilePicUrl = imageUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Image updated successfully! Ready to save."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error uploading picture: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Authentication error");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': _nameController.text.trim(),
            'contact': _contactController.text.trim(),
            'profilePicUrl': _currentProfilePicUrl ?? '',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Show a checkmark icon to save, disable while saving
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : IconButton(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.check),
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lightBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val!.isEmpty
                          ? 'Please enter your contact number'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: paleBlue,
            backgroundImage: _imageBytes != null
                ? MemoryImage(_imageBytes!)
                : (_currentProfilePicUrl != null &&
                              _currentProfilePicUrl!.isNotEmpty
                          ? NetworkImage(_currentProfilePicUrl!)
                          : null)
                      as ImageProvider?,
            child:
                _imageBytes == null &&
                    (_currentProfilePicUrl == null ||
                        _currentProfilePicUrl!.isEmpty)
                ? const Icon(Icons.business, size: 50, color: darkBlue)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: lightBlue,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black45,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
