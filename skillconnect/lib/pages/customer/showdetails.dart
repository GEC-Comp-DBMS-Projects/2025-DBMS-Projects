import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowDetailsPage extends StatefulWidget {
  final String jobId;
  const ShowDetailsPage({super.key, required this.jobId});

  @override
  State<ShowDetailsPage> createState() => _ShowDetailsPageState();
}

class _ShowDetailsPageState extends State<ShowDetailsPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  String? title;
  String? description;
  List<dynamic> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          title = data['title'] ?? 'No Title';
          description = data['description'] ?? 'No Description Provided';
          imageUrls = List<String>.from(data['imageUrls'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching job details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          "Job Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: lightBlue))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: title == null
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            style: const TextStyle(
                              color: darkBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: grayBlue,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildImagesSection(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        "Job details not found.",
        style: TextStyle(
          color: grayBlue,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    if (imageUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: paleBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "No images uploaded for this job.",
            style: TextStyle(
              color: grayBlue,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Job Images",
          style: TextStyle(
            color: darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 160,
                  color: paleBlue.withValues(alpha: 0.3),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: lightBlue),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: grayBlue.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: grayBlue,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
