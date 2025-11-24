import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  final bool isGuest;
  final String? guestName;
  
  const MainNavigationWrapper({super.key, this.initialIndex = 0, this.isGuest = false, this.guestName});

  @override
  State<MainNavigationWrapper> createState() => MainNavigationWrapperState();
}

class MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchToTab(int index) {
    // Restrict guest users from accessing restricted tabs
    if (widget.isGuest && (index == 1 || index == 2)) {
      _showGuestRestrictionDialog();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showGuestRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to access this feature. Guest users can only view available parking spots.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  List<Widget> get _screens {
    return [
      HomeScreen(isGuest: widget.isGuest, guestName: widget.guestName),
      HistoryScreen(isGuest: widget.isGuest),
      ProfileScreen(isGuest: widget.isGuest),
      const NotificationsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6F7F8),
        selectedItemColor: const Color(0xFF1173D4),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
