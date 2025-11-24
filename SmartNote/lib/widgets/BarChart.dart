// ignore_for_file: file_names

import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final List<double> values;

  const BarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values.map((v) {
            final scaledHeight = (v / maxValue) * 200;
            return Container(
              width: 24,
              height: scaledHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


