import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerJobDetailsPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const WorkerJobDetailsPage({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final String jobId = jobData['jobId'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Job Info ---
            Text(
              jobData['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              jobData['description'] ?? 'No Description Available',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30, thickness: 1.2),

            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- StreamBuilder to fetch reviews ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('jobId', isEqualTo: jobId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'No reviews yet for this job.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final reviewData =
                        reviews[index].data() as Map<String, dynamic>;

                    final rating = reviewData['rating'] ?? 0;
                    final reviewText = reviewData['review'] ?? '';
                    final reviewerName =
                        reviewData['reviewerName'] ?? 'Anonymous';
                    final createdAt = reviewData['createdAt'] != null
                        ? (reviewData['createdAt'] as Timestamp).toDate()
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reviewer name + date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  reviewerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (createdAt != null)
                                  Text(
                                    "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Rating stars
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < rating
                                      ? Icons.star
                                      : Icons.star_border_outlined,
                                  color: Colors.amber,
                                  size: 22,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),

                            // Review text
                            Text(
                              reviewText,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
