import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsByDatePage extends StatelessWidget {
  final String vehicleDocId;

  const BookingsByDatePage({Key? key, required this.vehicleDocId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingsRef = FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleDocId)
        .collection('bookings')
        .orderBy('startDate');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 14, 147),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/blue1.jpeg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          StreamBuilder<QuerySnapshot>(
            stream: bookingsRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading bookings: ${snapshot.error}'),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                    child: Text(
                  'No bookings for this vehicle.',
                  style: TextStyle(color: Colors.white),
                ));
              }

              // Group bookings by start date
              final Map<String, List<QueryDocumentSnapshot>> bookingsByDate = {};
              for (var doc in docs) {
                final data = doc.data()! as Map<String, dynamic>;
                final Timestamp ts = data['startDate'] as Timestamp;
                final dateStr = ts.toDate().toIso8601String().substring(0, 10); // yyyy-MM-dd

                bookingsByDate.putIfAbsent(dateStr, () => []).add(doc);
              }

              final sortedDates = bookingsByDate.keys.toList()..sort();

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final bookings = bookingsByDate[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...bookings.map((bookingDoc) {
                        final data = bookingDoc.data()! as Map<String, dynamic>;

                        final bookingRef = data['bookingRef'] ?? 'N/A';
                        final quantity = data['quantity']?.toString() ?? 'N/A';
                        final totalPrice = data['totalPrice']?.toString() ?? 'N/A';
                        final startDate = (data['startDate'] as Timestamp).toDate();
                        final endDate = (data['endDate'] as Timestamp).toDate();
                        final uname = data['uname'] ?? 'Unknown User';
                        final uid = data['uid'] ?? 'Unknown UID';
                        final numberOfDays= startDate.difference(endDate).inDays.abs()+1;

                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Ref: $bookingRef',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('User Name: $uname'),
                                Text('User ID: $uid'),
                                const SizedBox(height: 6),
                                Text('Quantity: $quantity'),
                                Text('Total Price: ₹$totalPrice'),
                                Text('Number of Days: $numberOfDays'),
                                Text(
                                    'From: ${startDate.toLocal().toString().split(' ')[0]}'),
                                Text(
                                    'To: ${endDate.toLocal().toString().split(' ')[0]}'),
                                Text('Cardnumber: ${data['creditcardNumber'] ?? 'N/A'}'),
                                Text('expirydate: ${data['expiryDate'] ?? 'N/A'}'),
                                Text('cvv: ${data['cvv'] ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
