import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmSlotScreen extends StatelessWidget {
  final String slotId;
  final bool available;

  const ConfirmSlotScreen({super.key, required this.slotId, required this.available});

  Future<void> _checkExistingParkingAndBook(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Check if user already has an active parking spot
      final existingSpotQuery = await FirebaseFirestore.instance
          .collection('parking_spots')
          .where('occupiedBy', isEqualTo: userId)
          .where('isOccupied', isEqualTo: true)
          .get();

      if (existingSpotQuery.docs.isNotEmpty) {
        final existingSpotData = existingSpotQuery.docs.first.data();
        final existingSpotName = existingSpotData['name'] ?? 'Unknown';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are already parked at spot $existingSpotName. Please unpark first before parking at another spot.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // If no existing parking, proceed with booking
      _showBookingConfirmation(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking existing parking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Do you want to book slot $slotId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual booking logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Slot $slotId booking functionality not yet implemented'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Book Slot'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Parkapp',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x1A1173D4),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: const Icon(
                  Icons.local_parking,
                  color: Color(0xFF1173D4),
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Slot $slotId',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                available ? 'This slot is currently available.' : 'This slot is currently occupied.',
                style: TextStyle(
                  fontSize: 16,
                  color: available ? const Color(0xFF64748B) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 40),
              if (available) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173D4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () => _checkExistingParkingAndBook(context),
                    child: const Text('Book Slot'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x1A1173D4),
                      foregroundColor: const Color(0xFF1173D4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text('Leave Slot'),
                  ),
                ),
              ],
              if (!available) ...[
                const SizedBox(height: 16),
                Text(
                  'Slot is already occupied. Search another slot.',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Note: Admin can override your booking if needed.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6F7F8),
        selectedItemColor: const Color(0xFF1173D4),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
