import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hoteldet.dart';
import 'rentaldet.dart';
import 'hotellist.dart';
import 'vehiclelist.dart';

class HotelBookingsPage extends StatelessWidget {
  const HotelBookingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hotel Bookings")),
      body: const Center(child: Text("Hotel Bookings Page")),
    );
  }
}

class RentalBookingsPage extends StatelessWidget {
  const RentalBookingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rental Bookings")),
      body: const Center(child: Text("Rental Bookings Page")),
    );
  }
}

// The HomePage
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/signin'); // Adjust route if needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    'Admin Menu',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.hotel),
                title: const Text('View Hotels'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyHotelsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.house),
                title: const Text('View Rental Bookings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VehicleListPage()),
                  );
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Dashboard',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 31, 12, 113),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/blue1.jpeg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Admin',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.hotel, size: 30),
                    label: const Text(
                      'Add Hotels',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      minimumSize: const Size(250, 60),
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddHotelPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.house, size: 30),
                    label: const Text(
                      'Add Rentals',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      minimumSize: const Size(250, 60),
                      backgroundColor: Colors.lightGreenAccent.shade700,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddVehiclePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

