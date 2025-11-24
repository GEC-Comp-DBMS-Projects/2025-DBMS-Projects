import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ShowReviewsPage extends StatelessWidget {
  final String jobId;

  const ShowReviewsPage({super.key, required this.jobId});

  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Job Reviews',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('jobId', isEqualTo: jobId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: lightBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final data = reviews[index].data() as Map<String, dynamic>;
              return _buildReviewCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    final workerName = data['workerName'] ?? 'Unknown Worker';
    final rating = (data['rating'] ?? 0).toDouble();
    final review = data['review'] ?? 'No review provided';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Title: Experience Text ---
            const Text(
              "Rate your experience with",
              style: TextStyle(fontSize: 15, color: grayBlue),
            ),
            const SizedBox(height: 4),

            // --- Worker Name ---
            Text(
              workerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 10),

            // --- Star Rating (Manual icons, like in review.dart) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                if (index < rating.floor()) {
                  return const Icon(Icons.star, color: lightBlue, size: 28);
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: lightBlue,
                    size: 28,
                  );
                }
              }),
            ),

            const SizedBox(height: 12),

            // --- Review Text Box ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: lightBlue, width: 1),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Text(
                review,
                style: const TextStyle(color: grayBlue, fontSize: 15),
              ),
            ),

            const SizedBox(height: 12),

            // --- Date ---
            if (createdAt != null)
              Text(
                "Reviewed on ${DateFormat('d MMM yyyy').format(createdAt)}",
                style: const TextStyle(color: grayBlue, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.reviews_outlined,
            size: 80,
            color: grayBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "No reviews yet for this job.",
            textAlign: TextAlign.center,
            style: TextStyle(color: grayBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
