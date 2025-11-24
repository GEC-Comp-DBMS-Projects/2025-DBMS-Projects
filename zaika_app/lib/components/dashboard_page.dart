import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_signin_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_page.dart';
import 'booking_page.dart';
import 'feedback_page.dart';
import 'order_page.dart'; // ✅ Import OrderPage

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({super.key, required this.userName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  Widget getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const OrdersPage(); // ✅ Navigate to OrderPage
        case 2:
        return const MenuPage();
      case 3:
        return const FeedbackPage();
      case 4:
        return const BookingPage();
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF625D9F),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/zaika_logo.png', height: 40),
            const SizedBox(width: 10),
            Image.asset('assets/images/zaika_text_purple.png', height: 40),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSignInPage()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFF625D9F),
                child: Icon(Icons.logout, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'DineIN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: 'Booking',
          ),
        ],
      ),
    );
  }

  // ----------------- HOME PAGE CONTENT -----------------
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Text
          Text(
            'Welcome, ${widget.userName} 👋',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A148C),
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.deepPurple.withOpacity(0.3),
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/zaika_restaurant.jpeg',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 25),

          // Option Cards
          buildOptionCard(
            context,
            'Book Table',
            'assets/images/book.jpeg',
            Colors.orange,
          ),
          const SizedBox(height: 16),
          buildOptionCard(
            context,
            'Dine In',
            'assets/images/menu.jpeg',
            Colors.green,
          ),
          const SizedBox(height: 16),
          buildOptionCard(
            context,
            'Order Food',
            'assets/images/order.jpeg',
            Colors.purple,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ----------------- OPTION CARD BUILDER -----------------
  Widget buildOptionCard(
    BuildContext context,
    String title,
    String imagePath,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: color.withOpacity(0.4),
        child: InkWell(
          onTap: () {
            if (title == 'Dine In') {
              setState(() => _selectedIndex = 2); // Navigate to MenuPage
            } else if (title == 'Book Table') {
              setState(() => _selectedIndex = 4); // Navigate to BookingPage
            } else if (title == 'Order Food') {
              setState(() => _selectedIndex = 1); // ✅ Navigate to Orders
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
