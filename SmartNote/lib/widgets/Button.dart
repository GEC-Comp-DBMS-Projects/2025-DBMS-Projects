// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AddGroupButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const AddGroupButton({
    super.key,
    required this.buttonText,
    this.onPressed,
  });

  @override
  State<AddGroupButton> createState() => _AddGroupButtonState();
}

class _AddGroupButtonState extends State<AddGroupButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Add padding here
      child: ElevatedButton.icon(
        onPressed: widget.onPressed,
        icon: const Icon(Icons.arrow_forward),
        label: Text(widget.buttonText),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20), // internal padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}
