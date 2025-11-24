import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'main_navigation_wrapper.dart';
import 'parking_map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/parking_spot.dart';
import 'admin_dashboard_screen.dart';
import 'models/parking_history.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;
  final String? guestName;
  
  const HomeScreen({super.key, this.isGuest = false, this.guestName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userName;
  bool _isLoadingName = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _loadUserName();
    } else {
      _isLoadingName = false;
    }
  }

  Future<void> _loadUserName() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _userName = doc.data()!['name'] as String?;
            _userRole = doc.data()!['role'] as String?;
            _isLoadingName = false;
          });
        } else {
          setState(() {
            _isLoadingName = false;
          });
        }
      } else {
        setState(() {
          _isLoadingName = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  bool get _isAdmin => (_userRole?.toLowerCase() == 'admin') || (_userRole?.toLowerCase() == 'staff');

  String _getGreeting() {
    if (widget.isGuest) {
      return 'Welcome, ${widget.guestName ?? 'Guest'}';
    }
    
    if (_isLoadingName) {
      return 'Welcome';
    }
    
    if (_userName != null && _userName!.isNotEmpty) {
      // Extract first name
      final firstName = _userName!.split(' ').first;
      return 'Hello, $firstName!';
    }
    
    return 'Welcome';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _getGreeting(),
          style: const TextStyle(
            color: Color.fromARGB(255, 33, 150, 243),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF64748B)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
        leading: const SizedBox(width: 48),
      ),
      body: SafeArea(
        child: widget.isGuest
            ? _buildGuestView()
            : _buildAuthenticatedView(),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 32),
            const Text(
              'Guest Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You are browsing as a guest. You can view available parking spots, but need to login to park your vehicle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 32),
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ParkingMapScreen(isGuest: true),
                    ),
                  );
                },
                child: const Text('View Available Parking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('parking_spots')
          .where('occupiedBy', isEqualTo: _auth.currentUser?.uid)
          .where('isOccupied', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final userParkedSpots = snapshot.data?.docs ?? [];
        final hasParkedSpot = userParkedSpots.isNotEmpty;
        final parkedSpot = hasParkedSpot 
            ? ParkingSpot.fromMap(userParkedSpots.first.data() as Map<String, dynamic>)
            : null;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasParkedSpot) ...[
                      // Parked Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_parking,
                              size: 60,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Currently Parked',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Spot ${parkedSpot!.name} (${parkedSpot.type})',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green.shade600,
                              ),
                            ),
                            if (parkedSpot.vehicleName != null || parkedSpot.isGuestVehicle) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      parkedSpot.isGuestVehicle 
                                          ? Icons.person_outline 
                                          : Icons.directions_car,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      parkedSpot.isGuestVehicle 
                                          ? 'Guest Vehicle'
                                          : parkedSpot.vehicleName ?? 'Unknown Vehicle',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (parkedSpot.vehicleLicensePlate != null && !parkedSpot.isGuestVehicle) ...[
                                const SizedBox(height: 4),
                                Text(
                                  parkedSpot.vehicleLicensePlate!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _unparkVehicle(parkedSpot),
                                    icon: const Icon(Icons.directions_car),
                                    label: const Text('Unpark'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ParkingMapScreen(isGuest: widget.isGuest),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map),
                                    label: const Text('View Map'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 33, 150, 243),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // No Parking Status
                      const Icon(
                        Icons.local_parking,
                        size: 80,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'No Active Parking',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "You currently don't have a parked vehicle.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 32),
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
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ParkingMapScreen(isGuest: widget.isGuest),
                              ),
                            );
                          },
                          child: const Text('Find Parking'),
                        ),
                      ),
                    ],
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
                        onPressed: () {
                          // Find the MainNavigationWrapper and switch to history tab
                          final mainNavWrapper = context.findAncestorStateOfType<MainNavigationWrapperState>();
                          if (mainNavWrapper != null) {
                            mainNavWrapper.switchToTab(1); // Switch to History tab
                          }
                        },
                        child: const Text('My Parking History'),
                      ),
                    ),
                    if (_isAdmin) ...[
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
                            fontSize: 19,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                          MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                            ),
          );
                        },
                        child: const Text('Admin Dashboard'),
                      ),
                    ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
  }

  Future<void> _unparkVehicle(ParkingSpot spot) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpark Vehicle'),
        content: Text('Are you sure you want to unpark from spot ${spot.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmUnpark(spot);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unpark'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUnpark(ParkingSpot spot) async {
    try {
      final now = DateTime.now();
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate parking duration
      final parkedAt = spot.occupiedAt ?? now;
      final duration = now.difference(parkedAt);

      // Create parking history record
      final historyId = _firestore.collection('parking_history').doc().id;
      final parkingHistory = ParkingHistory(
        id: historyId,
        userId: userId,
        spotId: spot.id,
        spotName: spot.name,
        spotType: spot.type,
        parkedAt: parkedAt,
        unparkedAt: now,
        duration: duration,
        vehicleId: spot.vehicleId,
        vehicleName: spot.vehicleName,
        vehicleLicensePlate: spot.vehicleLicensePlate,
        vehicleType: spot.vehicleType,
        isGuestVehicle: spot.isGuestVehicle,
        createdAt: now,
      );

      // Batch write to ensure both operations succeed or fail together
      final batch = _firestore.batch();
      
      // Update the parking spot to mark it as unoccupied and clear vehicle data
      batch.update(_firestore.collection('parking_spots').doc(spot.id), {
        'isOccupied': false,
        'occupiedBy': FieldValue.delete(), // Remove the field entirely
        'occupiedAt': FieldValue.delete(), // Remove the field entirely
        'vehicleId': FieldValue.delete(), // Remove vehicle ID
        'vehicleName': FieldValue.delete(), // Remove vehicle name
        'vehicleLicensePlate': FieldValue.delete(), // Remove license plate
        'vehicleType': FieldValue.delete(), // Remove vehicle type
        'isGuestVehicle': false, // Reset guest vehicle flag
        'updatedAt': now.toIso8601String(),
      });

      // Add parking history record
      batch.set(_firestore.collection('parking_history').doc(historyId), parkingHistory.toMap());

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unparked from spot ${spot.name}! Duration: ${parkingHistory.formattedDuration}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error unparking vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
