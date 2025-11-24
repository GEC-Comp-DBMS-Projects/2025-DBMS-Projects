import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AddEventDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? eventData;
final String uid;
final String role;
 const AddEventDialog({
  super.key,
  required this.onAdd,
  required this.uid,
  required this.role,
  this.eventData,
});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _categoryController;
  late TextEditingController _contactController;
  late TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventData?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.eventData?['description'] ?? '');
    _locationController = TextEditingController(text: widget.eventData?['location'] ?? '');
    _dateController = TextEditingController(text: widget.eventData?['date'] ?? '');
    _timeController = TextEditingController(text: widget.eventData?['time'] ?? '');
    _categoryController = TextEditingController(text: widget.eventData?['category'] ?? '');
    _contactController = TextEditingController(text: widget.eventData?['contactNumber'] ?? '');
    _feeController = TextEditingController(text: widget.eventData?['fee']?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    _contactController.dispose();
    _feeController.dispose();
    super.dispose();
  }

Future<void> _saveEvent() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to create an event")),
      );
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'date': _dateController.text.trim(),
      'time': _timeController.text.trim(),
      'category': _categoryController.text.trim(),
      'contactNumber': _contactController.text.trim(),
      'fee': double.tryParse(_feeController.text) ?? 0.0,
      'createdAt': DateTime.now(),
      'attendeesCount': widget.eventData?['attendeesCount'] ?? 0,

      // ✅ Add this line
      'organizationId': currentUser.uid,
    };

    await widget.onAdd(data);
    if (mounted) Navigator.pop(context);
  } catch (e, st) {
    debugPrint("🔥 Error saving event: $e");
    debugPrintStack(stackTrace: st);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving event: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.eventData == null ? "Add Event" : "Edit Event"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location")),
            TextField(controller: _dateController, decoration: const InputDecoration(labelText: "Date")),
            TextField(controller: _timeController, decoration: const InputDecoration(labelText: "Time")),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: _contactController, decoration: const InputDecoration(labelText: "Contact Number")),
            TextField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Fee (₹)"),
            ),
          ],
        ),
      ),
      actions: [
      TextButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(uid: widget.uid, role: widget.role),
      ),
    );
  },
  child: const Text("Cancel"),
),

        ElevatedButton(
          onPressed: _saveEvent,
          child: Text(widget.eventData == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}
