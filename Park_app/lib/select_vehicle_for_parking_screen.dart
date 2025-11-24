import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/vehicle.dart';
import 'models/parking_spot.dart';

class SelectVehicleForParkingScreen extends StatefulWidget {
  final ParkingSpot spot;

  const SelectVehicleForParkingScreen({
    super.key,
    required this.spot,
  });

  @override
  State<SelectVehicleForParkingScreen> createState() => _SelectVehicleForParkingScreenState();
}

class _SelectVehicleForParkingScreenState extends State<SelectVehicleForParkingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Vehicle? _selectedVehicle;
  bool _isGuestVehicle = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Select Vehicle',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Spot Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1173D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: Color(0xFF1173D4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spot ${widget.spot.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.spot.type} Parking',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Guest Vehicle Option
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isGuestVehicle ? const Color(0xFF1173D4) : Colors.grey.shade300,
                    width: _isGuestVehicle ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isGuestVehicle 
                          ? const Color(0xFF1173D4).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: _isGuestVehicle ? const Color(0xFF1173D4) : Colors.grey.shade600,
                    ),
                  ),
                  title: const Text(
                    'Guest Vehicle',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Park a vehicle without details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  trailing: Radio<bool>(
                    value: true,
                    groupValue: _isGuestVehicle,
                    onChanged: (value) {
                      setState(() {
                        _isGuestVehicle = true;
                        _selectedVehicle = null;
                      });
                    },
                    activeColor: const Color(0xFF1173D4),
                  ),
                  onTap: () {
                    setState(() {
                      _isGuestVehicle = true;
                      _selectedVehicle = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // My Vehicles Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('vehicles')
                    .orderBy('createdAt', descending: true)
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

                  final allVehicles = snapshot.data?.docs
                      .map((doc) => Vehicle.fromMap(doc.data() as Map<String, dynamic>))
                      .toList() ?? [];

                  // Filter vehicles based on spot type
                  final vehicles = _filterVehiclesBySpotType(allVehicles);

                  if (vehicles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getSpotIcon(widget.spot.type),
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No compatible vehicles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a ${widget.spot.type} vehicle to your profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final isSelected = _selectedVehicle?.id == vehicle.id && !_isGuestVehicle;
                      // Note: All vehicles in this list are already filtered to be compatible

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF1173D4) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF1173D4).withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getVehicleIcon(vehicle.type),
                                color: isSelected ? const Color(0xFF1173D4) : Colors.grey.shade600,
                              ),
                            ),
                              title: Text(
                              vehicle.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.licensePlate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Radio<Vehicle>(
                              value: vehicle,
                              groupValue: _selectedVehicle,
                              onChanged: (value) {
                                setState(() {
                                  _selectedVehicle = value;
                                  _isGuestVehicle = false;
                                });
                              },
                              activeColor: const Color(0xFF1173D4),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedVehicle = vehicle;
                                _isGuestVehicle = false;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Info Card for Vehicle Type Restriction
            Builder(
              builder: (context) {
                final allVehiclesSnapshot = StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_auth.currentUser?.uid)
                      .collection('vehicles')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    
                    final allVehicles = snapshot.data!.docs
                        .map((doc) => Vehicle.fromMap(doc.data() as Map<String, dynamic>))
                        .toList();
                    
                    final compatibleVehicles = _filterVehiclesBySpotType(allVehicles);
                    
                    if (allVehicles.isNotEmpty && compatibleVehicles.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This spot is for ${widget.spot.type} only. Add a ${widget.spot.type} vehicle to park here.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
                return allVehiclesSnapshot;
              },
            ),

            // Park Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
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
                  onPressed: (_selectedVehicle != null || _isGuestVehicle) && !_isLoading
                      ? () => _parkVehicle()
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Park Here'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'truck':
        return Icons.local_shipping;
      case 'bicycle':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  IconData _getSpotIcon(String spotType) {
    if (spotType == '2-wheeler') {
      return Icons.two_wheeler;
    } else {
      return Icons.directions_car;
    }
  }

  List<Vehicle> _filterVehiclesBySpotType(List<Vehicle> vehicles) {
    return vehicles.where((vehicle) {
      // Map vehicle types to spot types
      if (widget.spot.type == '2-wheeler') {
        // 2-wheeler vehicles
        return vehicle.type.toLowerCase() == 'motorcycle' || 
               vehicle.type.toLowerCase() == 'bicycle' ||
               vehicle.type.toLowerCase() == 'scooter';
      } else {
        // 4-wheeler vehicles
        return vehicle.type.toLowerCase() == 'car' || 
               vehicle.type.toLowerCase() == 'truck' ||
               vehicle.type.toLowerCase() == 'suv' ||
               vehicle.type.toLowerCase() == 'van';
      }
    }).toList();
  }

  bool _isVehicleCompatible(Vehicle vehicle) {
    if (widget.spot.type == '2-wheeler') {
      return vehicle.type.toLowerCase() == 'motorcycle' || 
             vehicle.type.toLowerCase() == 'bicycle' ||
             vehicle.type.toLowerCase() == 'scooter';
    } else {
      return vehicle.type.toLowerCase() == 'car' || 
             vehicle.type.toLowerCase() == 'truck' ||
             vehicle.type.toLowerCase() == 'suv' ||
             vehicle.type.toLowerCase() == 'van';
    }
  }

  Future<void> _parkVehicle() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user already has an active parking spot
      final existingSpotQuery = await _firestore
          .collection('parking_spots')
          .where('occupiedBy', isEqualTo: userId)
          .where('isOccupied', isEqualTo: true)
          .get();

      if (existingSpotQuery.docs.isNotEmpty) {
        final existingSpot = ParkingSpot.fromMap(existingSpotQuery.docs.first.data());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are already parked at spot ${existingSpot.name}. Please unpark first before parking at another spot.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Prepare vehicle data
      String? vehicleId;
      String? vehicleName;
      String? vehicleLicensePlate;
      String? vehicleType;
      bool isGuestVehicle = _isGuestVehicle;

      if (!_isGuestVehicle && _selectedVehicle != null) {
        vehicleId = _selectedVehicle!.id;
        vehicleName = _selectedVehicle!.name;
        vehicleLicensePlate = _selectedVehicle!.licensePlate;
        vehicleType = _selectedVehicle!.type;
      }

      // Update the parking spot with vehicle information
      final updatedSpot = widget.spot.copyWith(
        isOccupied: true,
        occupiedBy: userId,
        occupiedAt: now,
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        vehicleLicensePlate: vehicleLicensePlate,
        vehicleType: vehicleType,
        isGuestVehicle: isGuestVehicle,
        updatedAt: now,
      );

      await _firestore
          .collection('parking_spots')
          .doc(widget.spot.id)
          .update(updatedSpot.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully parked at spot ${widget.spot.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to map
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parking vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
