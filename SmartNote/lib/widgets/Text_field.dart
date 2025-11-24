// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController c;

  const CustomTextField({super.key, required this.label, required this.c});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: widget.c,
          decoration: InputDecoration(
            labelText: widget.label,
            border: InputBorder.none,
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 74, 49, 12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CommentTextField extends StatefulWidget {
  final Function(String) onSend;
  final String label;
  const CommentTextField({
    super.key,
    required this.label,
    required this.onSend,
  });

  @override
  State<CommentTextField> createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  final c = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      maxLines: null,
      decoration: InputDecoration(
        label: Text(widget.label),
        suffixIcon: IconButton(
          onPressed: () {
            widget.onSend(c.text);
            c.clear();
          },
          icon: Icon(Icons.send),
        ),
      ),
    );
  }
}
