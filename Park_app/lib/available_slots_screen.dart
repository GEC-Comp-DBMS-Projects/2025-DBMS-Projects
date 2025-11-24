import 'package:flutter/material.dart';
import 'confirm_slot_screen.dart';

class AvailableSlotsScreen extends StatelessWidget {
  const AvailableSlotsScreen({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: 20,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),
        itemBuilder: (context, index) {
          // Demo: every 5th slot is occupied
          final slotId = 'A-${(index + 1).toString().padLeft(2, '0')}';
          final bool available = index % 5 != 0;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_parking, color: available ? Colors.green : Colors.red, size: 32),
            ),
            title: Text(
              'Slot #$slotId',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A202C),
              ),
            ),
            subtitle: Text(
              available ? 'Available' : 'Occupied',
              style: TextStyle(
                color: available ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              if (available) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmSlotScreen(
                      slotId: slotId,
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
          );
        },
      ),
    );
  }
}
