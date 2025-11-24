import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingOverviewPage extends StatefulWidget {
  final String hotelId;

  const BookingOverviewPage({Key? key, required this.hotelId})
    : super(key: key);

  @override
  State<BookingOverviewPage> createState() => _BookingOverviewPageState();
}

class _BookingOverviewPageState extends State<BookingOverviewPage> {
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/blue1.jpeg', fit: BoxFit.cover),
          ),
          // Semi-transparent overlay
          Container(color: Colors.black.withOpacity(0.5)),
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  iconTheme: const IconThemeData(color: Colors.white),
                  backgroundColor: const Color.fromARGB(255, 7, 19, 66),
                  elevation: 0,
                  title: const Text(
                    'Hotel Bookings by Stay Dates',
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBookingList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    final bookingsRef = FirebaseFirestore.instance
        .collection('Hotels')
        .doc(widget.hotelId)
        .collection('bookings');

    return StreamBuilder<QuerySnapshot>(
      stream: bookingsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading bookings: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No bookings found.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        final Map<String, List<Map<String, dynamic>>> groupedBookings = {};

        for (var doc in docs) {
          final data = doc.data()! as Map<String, dynamic>;
          final checkInTimestamp = data['checkInDate'] as Timestamp?;
          final checkOutTimestamp = data['checkOutDate'] as Timestamp?;

          if (checkInTimestamp == null || checkOutTimestamp == null) continue;

          final checkInDate = DateTime(
            checkInTimestamp.toDate().year,
            checkInTimestamp.toDate().month,
            checkInTimestamp.toDate().day,
          );
          final checkOutDate = DateTime(
            checkOutTimestamp.toDate().year,
            checkOutTimestamp.toDate().month,
            checkOutTimestamp.toDate().day,
          );

          for (
            DateTime day = checkInDate;
            day.isBefore(checkOutDate);
            day = day.add(const Duration(days: 1))
          ) {
            final key = dateFormatter.format(day);
            groupedBookings.putIfAbsent(key, () => []);
            groupedBookings[key]!.add(data);
          }
        }

        final sortedKeys = groupedBookings.keys.toList()
          ..sort(
            (a, b) => dateFormatter.parse(a).compareTo(dateFormatter.parse(b)),
          );

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final key = sortedKeys[index];
            final bookings = groupedBookings[key]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...bookings
                    .map((booking) => _buildBookingCard(booking))
                    .toList(),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final String userName = booking['userName'] ?? 'N/A';
    final String bookingRef = booking['bookingRef'] ?? 'N/A';

    final List<dynamic> rooms = booking['rooms'] ?? [];

    final Timestamp checkInTimestamp = booking['checkInDate'] as Timestamp;
    final Timestamp checkOutTimestamp = booking['checkOutDate'] as Timestamp;

    final DateTime checkInDate = checkInTimestamp.toDate();
    final DateTime checkOutDate = checkOutTimestamp.toDate();

    return SizedBox(
      width: double.infinity, // full width
      child: Card(
        color: Colors.white.withOpacity(0.9),
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Booking Ref
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bookingRef,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Loop through all rooms
              ...rooms.asMap().entries.map((entry) {
                final index = entry.key + 1; // Room 1, Room 2, ...
                final room = entry.value as Map<String, dynamic>;

                final String roomType = room['roomType']?.toString() ?? 'N/A';
                final List<dynamic> guests = room['guests'] ?? [];
                final String guestNames = guests.isNotEmpty
                    ? guests.join(', ')
                    : 'N/A';
                final bool isAC = room['isAC'] ?? false;
                final roomPrice = room['price'] != null
                    ? '₹${room['price']}'
                    : 'N/A';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room $index: $roomType',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Guests: $guestNames',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Price: $roomPrice',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 8),
              Text(
                'Check-In: ${dateFormatter.format(checkInDate)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Check-Out: ${dateFormatter.format(checkOutDate)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text('Cardnumber: ${booking['creditcardnumber'] ?? 'N/A'}'),
              Text('expirydate: ${booking['expirydate'] ?? 'N/A'}'),
              Text('cvv: ${booking['cvv'] ?? 'N/A'}'),
            ],
          ),
        ),
      ),
    );
  }
}
