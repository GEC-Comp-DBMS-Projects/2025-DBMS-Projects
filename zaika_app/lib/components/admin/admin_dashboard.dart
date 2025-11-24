import 'package:flutter/material.dart';
import 'admin_items.dart';
import 'view_items.dart';
import 'view_orders.dart';
import 'view_bookings.dart';
import 'view_feedback.dart'; // Import the feedback page

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // Uniform professional button color
  final Color buttonColor = const Color(0xFF8173C3); // Muted purple/indigo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: buttonColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _DashboardButton(
              icon: Icons.add_circle,
              title: 'Add Item',
              color: buttonColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddFoodItemPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _DashboardButton(
              icon: Icons.list_alt,
              title: 'View Items',
              color: buttonColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewItemsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _DashboardButton(
              icon: Icons.receipt_long,
              title: 'View Orders',
              color: buttonColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewOrdersPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _DashboardButton(
              icon: Icons.event_available,
              title: 'View Bookings',
              color: buttonColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewBookingsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _DashboardButton(
              icon: Icons.feedback,
              title: 'View Feedback',
              color: buttonColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ViewFeedbackPage(), // Navigate to feedback page
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
