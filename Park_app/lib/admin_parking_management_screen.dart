import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/parking_spot.dart';
import 'models/parking_history.dart';

class AdminParkingManagementScreen extends StatefulWidget {
  const AdminParkingManagementScreen({super.key});

  @override
  State<AdminParkingManagementScreen> createState() => _AdminParkingManagementScreenState();
}

class _AdminParkingManagementScreenState extends State<AdminParkingManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransformationController _transformationController = TransformationController();
  // Removed vehicle type filter dropdown and state
  bool _showMap = true;
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Manage Parking'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
        // Removed dropdown filter
      ),
      body: SafeArea(
        child: _showMap ? _buildMapView() : _buildListView(),
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildMapView() {
    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, 'Available'),
              _buildLegendItem(Colors.red, 'Occupied'),
            ],
          ),
        ),
        // Map
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 3.0,
                child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('parking_spots').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No parking spots available'));
                    }

                    final spots = snapshot.data!.docs
                        .map((doc) => ParkingSpot.fromMap(doc.data() as Map<String, dynamic>))
                        .toList();

                    return SizedBox(
                      width: 400.0,
                      height: 600.0,
                      child: Stack(
                        children: [
                          // Background map
                          Container(
                            width: 400.0,
                            height: 600.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Horizontal road at top
                                Positioned(
                                  left: 0,
                                  top: -20,
                                  child: Container(
                                    width: 400.0,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade600,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                                // Main road (vertical)
                                Positioned(
                                  left: 400.0 * 0.468 - 12,
                                  top: -40,
                                  child: Container(
                                    width: 50,
                                    height: 522,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade600,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                // Comp/Ene Building
                                Positioned(
                                  left: -14.8,
                                  bottom: 0,
                                  child: Container(
                                    width: 80,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade600, width: 2),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Comp/Ene\nBuilding',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                // Computer Department
                                Positioned(
                                  left: 158,
                                  bottom: 0,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade600, width: 2),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Computer Department',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                // Mech Building
                                Positioned(
                                  left: 340,
                                  bottom: 0,
                                  child: Container(
                                    width: 80,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade600, width: 2),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Mech\nBuilding',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                // Horizontal road connecting buildings
                                Positioned(
                                  left: 64,
                                  bottom: 126,
                                  child: Container(
                                    width: 276,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade600,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                                // Vertical passage
                                Positioned(
                                  left: 106,
                                  top: 450,
          child: Container(
                                    width: 20,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade600,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Parking spots
                          ...spots.map((spot) => _buildParkingSpot(spot)),
                        ],
                      ),
                    );
              },
            ),
          ),
        ),
      ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('parking_spots').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final spots = snapshot.data?.docs.map((doc) => ParkingSpot.fromMap(doc.data() as Map<String, dynamic>)).toList() ?? [];

            if (spots.isEmpty) {
              return const Center(child: Text('No parking spots found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spots.length,
              itemBuilder: (context, index) {
                final spot = spots[index];
                return _buildSpotCard(spot);
              },
            );
          },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildParkingSpot(ParkingSpot spot) {
    final Color spotColor = spot.isOccupied ? Colors.red : Colors.green;
    const double mapWidth = 400.0;
    const double mapHeight = 600.0;
    final bool isTwoWheeler = spot.type == '2-wheeler';
    final bool isVerticalTwoWheeler = isTwoWheeler && spot.name.toUpperCase().startsWith('H');
    final double spotWidth = isTwoWheeler ? (isVerticalTwoWheeler ? 10.0 : 30.0) : 45.0;
    final double spotHeight = isTwoWheeler ? (isVerticalTwoWheeler ? 30.0 : 10.0) : 25.0;
    final double spotX = (spot.x * mapWidth) - (spotWidth / 2);
    final double spotY = (spot.y * mapHeight) - (spotHeight / 2);

    return Positioned(
      left: spotX,
      top: spotY,
      child: GestureDetector(
        onTap: () => _showSpotDetails(spot),
        child: Container(
          width: spotWidth,
          height: spotHeight,
          decoration: BoxDecoration(
            color: spotColor,
            shape: BoxShape.rectangle,
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              spot.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: spot.type == '2-wheeler' ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotCard(ParkingSpot spot) {
    Color statusColor = spot.isOccupied ? Colors.red : Colors.green;
    String statusText = spot.isOccupied ? 'Occupied' : 'Available';

    return FutureBuilder<Map<String, String?>>(
      future: spot.isOccupied && spot.occupiedBy != null 
          ? _getUserDetails(spot.occupiedBy!) 
          : Future.value({'name': null, 'phone': null, 'email': null}),
      builder: (context, snapshot) {
        final userName = snapshot.data?['name'] ?? 'Loading...';
        final userPhone = snapshot.data?['phone'] ?? '';
        final userEmail = snapshot.data?['email'] ?? '';
        
        return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
          child: ListTile(
            leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
              child: Icon(Icons.local_parking, color: statusColor, size: 24),
                  ),
            title: Text(
              'Spot ${spot.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
            subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: spot.type == '2-wheeler' ? Colors.green.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              spot.type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: spot.type == '2-wheeler' ? Colors.green.shade700 : Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                if (spot.isOccupied) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Occupied by: $userName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (userPhone.isNotEmpty)
                    Text(
                      'Phone: $userPhone',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (spot.vehicleName != null || spot.isGuestVehicle)
                    Text(
                      spot.isGuestVehicle ? 'Guest Vehicle' : spot.vehicleName ?? 'Unknown',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            ),
            trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                  onTap: () => _showSpotDetails(spot),
                ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                      Icon(Icons.history, size: 20),
                          SizedBox(width: 8),
                      Text('View History'),
                        ],
                      ),
                  onTap: () => _showSpotHistory(spot),
                    ),
                    if (spot.isOccupied)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.remove_circle, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Force Unpark', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () => _showForceUnparkDialog(spot),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpotDetails(ParkingSpot spot) {
    _showSpotDialog(spot);
  }

  void _showSpotDialog(ParkingSpot spot) async {
    String? userName = 'Loading...';
    String userPhone = '';
    String userEmail = '';
    
    if (spot.isOccupied && spot.occupiedBy != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(spot.occupiedBy).get();
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] as String?;
          userPhone = (userDoc.data()?['phone'] as String?) ?? 
                       (userDoc.data()?['phoneNumber'] as String?) ?? '';
          userEmail = (userDoc.data()?['email'] as String?) ?? '';
        }
      } catch (e) {
        userName = 'Unknown';
      }
    }
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Spot ${spot.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${spot.type}'),
                const SizedBox(height: 8),
                Text('Status: ${spot.isOccupied ? "Occupied" : "Available"}'),
            if (spot.isOccupied) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                      'Occupied by: $userName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (userEmail.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.email, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  userEmail,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (userPhone.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  userPhone,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                      ),
                    ],
                  ],
                ),
              ),
                  const SizedBox(height: 12),
                    if (spot.vehicleName != null || spot.isGuestVehicle) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                      Text(
                                'Vehicle Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                          ),
                          const SizedBox(height: 8),
                          Text('Vehicle: ${spot.isGuestVehicle ? 'Guest Vehicle' : spot.vehicleName ?? 'Unknown'}'),
                          if (spot.vehicleLicensePlate != null && !spot.isGuestVehicle)
                            Text('License: ${spot.vehicleLicensePlate}'),
                  ],
                ),
              ),
                    const SizedBox(height: 8),
                  ],
                  if (spot.occupiedAt != null)
                    Text('Parked at: ${_formatDateTime(spot.occupiedAt!)}'),
            ],
          ],
        ),
      ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSpotHistory(spot);
              },
              child: const Text('View History'),
            ),
            if (spot.isOccupied)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showForceUnparkDialog(spot);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Force Unpark'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _showSpotHistory(ParkingSpot spot) async {
    try {
      final historyQuery = await _firestore
          .collection('parking_history')
          .where('spotName', isEqualTo: spot.name)
          .get();

      final history = historyQuery.docs
          .map((doc) => ParkingHistory.fromMap(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.unparkedAt.compareTo(a.unparkedAt));

      if (context.mounted) {
        // Fetch user names for all history entries
        final List<Map<String, String>> historyWithNames = [];
        for (var entry in history) {
          final userName = await _getUserName(entry.userId);
          historyWithNames.add({
            'userName': userName ?? 'Unknown User',
            'userId': entry.userId,
          });
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('History - Spot ${spot.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: history.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No parking history for this spot',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        final userName = historyWithNames[index]['userName'] ?? 'Unknown';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1173D4).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Color(0xFF1173D4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (entry.vehicleName != null || entry.isGuestVehicle)
                                          Text(
                                            entry.isGuestVehicle ? 'Guest Vehicle' : entry.vehicleName ?? 'Unknown Vehicle',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildHistoryRow(Icons.access_time, entry.formattedDuration, Colors.orange),
                              const SizedBox(height: 4),
                              _buildHistoryRow(Icons.schedule, '${_formatDateTime(entry.parkedAt)} - ${_formatDateTime(entry.unparkedAt)}', Colors.green),
                              if (entry.vehicleLicensePlate != null && !entry.isGuestVehicle)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _buildHistoryRow(
                                    Icons.directions_car,
                                    'License: ${entry.vehicleLicensePlate}',
                                    Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  Widget _buildHistoryRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showForceUnparkDialog(ParkingSpot spot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Unpark'),
        content: Text('Are you sure you want to force unpark spot ${spot.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _forceUnpark(spot);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Force Unpark'),
          ),
        ],
      ),
    );
  }

  Future<void> _forceUnpark(ParkingSpot spot) async {
    try {
      await _firestore.collection('parking_spots').doc(spot.id).update({
        'isOccupied': false,
        'occupiedBy': FieldValue.delete(),
        'occupiedAt': FieldValue.delete(),
        'vehicleId': FieldValue.delete(),
        'vehicleName': FieldValue.delete(),
        'vehicleLicensePlate': FieldValue.delete(),
        'vehicleType': FieldValue.delete(),
        'isGuestVehicle': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spot force unparked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String?>> _getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        return {
          'name': data?['name'] as String?,
          'phone': data?['phone'] as String? ?? data?['phoneNumber'] as String?,
          'email': data?['email'] as String?,
        };
      }
      return {'name': null, 'phone': null, 'email': null};
    } catch (e) {
      return {'name': null, 'phone': null, 'email': null};
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Zoom buttons removed; InteractiveViewer gestures still enabled
}
