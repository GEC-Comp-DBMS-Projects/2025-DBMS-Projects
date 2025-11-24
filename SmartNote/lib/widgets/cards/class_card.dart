import 'package:flutter/material.dart';

class ClassCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const ClassCard({super.key, required this.data});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey,
      ),
      child: Column(
        children: [Text(widget.data['name']), Text(widget.data['description'])],
      ),
    );
  }
}
