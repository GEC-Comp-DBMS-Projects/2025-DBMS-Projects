import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBookingsPage extends StatelessWidget {
  const ViewBookingsPage({super.key});

  Stream<QuerySnapshot> getBookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateBookingStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(
        {'status': newStatus},
      );
    } catch (e) {
      debugPrint('Error updating booking: $e');
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] ?? 'No Name';
      }
      return 'User Not Found';
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      return 'Error';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Bookings'),
        backgroundColor: const Color(0xFF6C5DD3),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookings.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final booking = doc.data() as Map<String, dynamic>;
              final bookingId = booking['bookingId'] ?? 'Unknown ID';
              final date = booking['date'] ?? 'Unknown Date';
              final time = booking['time'] ?? 'Unknown Time';
              final members = booking['number_of_members'] ?? 0;
              final status = booking['status'] ?? 'Unknown';
              final userId = booking['userId'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          const Icon(
                            Icons.event_note,
                            color: Color(0xFF6C5DD3),
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Booking ID: $bookingId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: getStatusColor(status),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Booking Info
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 6),
                          Text(date),
                          const SizedBox(width: 20),
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text(time),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 18),
                          const SizedBox(width: 6),
                          Text('Members: $members'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18),
                          const SizedBox(width: 6),
                          FutureBuilder<String>(
                            future: getUserName(userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading user...');
                              } else if (snapshot.hasError) {
                                return const Text('Error');
                              } else {
                                final userName = snapshot.data ?? 'Unknown';
                                return Text(userName);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Accept / Reject Buttons
                      if (status.toLowerCase() == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  updateBookingStatus(doc.id, 'Accepted'),
                              icon: const Icon(Icons.check),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  updateBookingStatus(doc.id, 'Rejected'),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
