import 'package:flutter/material.dart';
import 'confirm_slot_screen.dart';

class TwoWheelerSlotsScreen extends StatelessWidget {
  const TwoWheelerSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example slot data (can be replaced with real-time data later)
    final slots = List.generate(40, (index) {
      // For demo: every 7th slot is occupied
      final slotNum = index + 1;
      final slotId = 'M${slotNum.toString().padLeft(2, '0')}';
      final isOccupied = slotNum % 7 == 0;
      return {
        'id': slotId,
        'available': !isOccupied,
      };
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Two-Wheeler Slots',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [const SizedBox(width: 40)],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: slots.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final bool isAvailable = slot['available'] as bool;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                'Slot ${slot['id']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF1A202C),
                ),
              ),
              subtitle: Text(
                isAvailable ? 'Available' : 'Occupied',
                style: TextStyle(
                  color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: isAvailable ? const Color(0xFF1173D4) : const Color(0xFF94A3B8),
                size: 20,
              ),
              onTap: () {
                if (isAvailable) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmSlotScreen(
                        slotId: slot['id'] as String,
                        available: true,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Slot is already occupied. Search another slot.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
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
