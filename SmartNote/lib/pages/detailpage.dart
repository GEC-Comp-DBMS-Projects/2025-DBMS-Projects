import 'package:flutter/material.dart';

import 'package:page_flip/page_flip.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPage({super.key, required this.data});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final controller = GlobalKey<PageFlipWidgetState>();

    // Get description
    String description =
        widget.data['description'] ?? 'No Description Available';

    // Split into pages of 300 characters
    int pageSize = 1000;
    List<String> pages = [];

    for (int i = 0; i < description.length; i += pageSize) {
      pages.add(
        description.substring(
          i,
          i + pageSize > description.length ? description.length : i + pageSize,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: PageFlipWidget(
        key: controller,
        backgroundColor: Colors.white,
        lastPage: Container(
          color: Colors.white,
          child: const Center(child: Text('Last Page!')),
        ),
        children:
            pages
                .map(
                  (pageText) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      pageText,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                )
                .toList(),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.looks_5_outlined),
        onPressed: () {
          controller.currentState?.goToPage(1); // Go to page 2 (0-indexed)
        },
      ),
    );
  }
}
