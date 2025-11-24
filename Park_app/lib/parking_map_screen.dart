import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/parking_spot.dart';
import 'select_vehicle_for_parking_screen.dart';
import 'login_screen.dart';

class ParkingMapScreen extends StatefulWidget {
  final bool isGuest;
  
  const ParkingMapScreen({super.key, this.isGuest = false});

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _checkAndCreateInitialSpots();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _checkAndCreateInitialSpots() async {
    // Only create initial parking spots if none exist
    final spotsSnapshot = await _firestore.collection('parking_spots').get();
    
    if (spotsSnapshot.docs.isEmpty) {
      // Create initial parking spots if none exist
      await _createInitialParkingSpots();
    } else {
      // Add missing spots if they don't exist
      await _addMissingSpots();
    }
  }

  // Removed spot deletion logic as requested

  Future<void> _addMissingSpots() async {
    // Get existing spot names
    final existingSpots = await _firestore.collection('parking_spots').get();
    final existingNames = existingSpots.docs.map((doc) => doc.data()['name'] as String).toSet();
    
    final now = DateTime.now();
    
    // 2-wheeler spots on either side of the passage (vertical road at x=0.265)
    // Left side of passage - 8 spots
    final twoWheelerSpotsCompEne = [
      {'name': 'E1', 'x': 0.20, 'y': 0.79},
      {'name': 'E2', 'x': 0.20, 'y': 0.81},
      {'name': 'E3', 'x': 0.20, 'y': 0.83},
      {'name': 'E4', 'x': 0.20, 'y': 0.85},
      {'name': 'E5', 'x': 0.20, 'y': 0.87},
      {'name': 'E6', 'x': 0.20, 'y': 0.89},
      {'name': 'E7', 'x': 0.20, 'y': 0.91},
      {'name': 'E8', 'x': 0.20, 'y': 0.93},
      {'name': 'E9', 'x': 0.20, 'y': 0.95},
      {'name': 'E10', 'x': 0.20, 'y': 0.97},
      {'name': 'E11', 'x': 0.20, 'y': 0.99},
      // Right side of passage - 8 spots
      {'name': 'E12', 'x': 0.354, 'y': 0.82},
      {'name': 'E13', 'x': 0.354, 'y': 0.84},
      {'name': 'E14', 'x': 0.354, 'y': 0.86},
      {'name': 'E15', 'x': 0.354, 'y': 0.88},
      {'name': 'E16', 'x': 0.354, 'y': 0.90},
      {'name': 'E17', 'x': 0.354, 'y': 0.92},
      {'name': 'E18', 'x': 0.354, 'y': 0.94},
      {'name': 'E19', 'x': 0.354, 'y': 0.96},
      {'name': 'E20', 'x': 0.354, 'y': 0.98},
      {'name': 'E21', 'x': 0.354, 'y': 1.00},
      //side of mech building
      {'name': 'E22', 'x': 0.83, 'y': 0.82},
      {'name': 'E23', 'x': 0.83, 'y': 0.84},
      {'name': 'E24', 'x': 0.83, 'y': 0.86},
      {'name': 'E25', 'x': 0.83, 'y': 0.88},
      {'name': 'E26', 'x': 0.83, 'y': 0.90},
      {'name': 'E27', 'x': 0.83, 'y': 0.92},
      {'name': 'E28', 'x': 0.83, 'y': 0.94},
      {'name': 'E29', 'x': 0.83, 'y': 0.96},
      {'name': 'E30', 'x': 0.83, 'y': 0.98},
    ];

    // 2-wheeler vertical spots placed along the horizontal road (centered on the road)
    // Names: H1-H12 spread across the horizontal road
    final twoWheelerSpotsHorizontal = [
      {'name': 'H1', 'x': 0.20, 'y': 0.72},
      {'name': 'H2', 'x': 0.23, 'y': 0.72},
      {'name': 'H3', 'x': 0.26, 'y': 0.72},
      {'name': 'H4', 'x': 0.29, 'y': 0.72},
      {'name': 'H5', 'x': 0.32, 'y': 0.72},
      {'name': 'H6', 'x': 0.35, 'y': 0.72},
      {'name': 'H7', 'x': 0.38, 'y': 0.72},
      {'name': 'H8', 'x': 0.41, 'y': 0.72},
      {'name': 'H9', 'x': 0.44, 'y': 0.72},
      {'name': 'H10', 'x': 0.74, 'y': 0.72},
      {'name': 'H11', 'x': 0.77, 'y': 0.72},
      {'name': 'H12', 'x': 0.80, 'y': 0.72},
      {'name': 'H13', 'x': 0.83, 'y': 0.72},
      {'name': 'H14', 'x': 0.35, 'y': 0.785},
      {'name': 'H15', 'x': 0.38, 'y': 0.785},
      {'name': 'H16', 'x': 0.41, 'y': 0.785},
      {'name': 'H17', 'x': 0.44, 'y': 0.785},
      {'name': 'H18', 'x': 0.54, 'y': 0.785},
      {'name': 'H19', 'x': 0.57, 'y': 0.785},
      {'name': 'H20', 'x': 0.60, 'y': 0.785},
      {'name': 'H21', 'x': 0.63, 'y': 0.785},
      //special nitesh spot
    ];

    // Add or update E1-E16 spots
    for (var spot in twoWheelerSpotsCompEne) {
      if (!existingNames.contains(spot['name'])) {
        // Add new spot
        final parkingSpot = ParkingSpot(
          id: _firestore.collection('parking_spots').doc().id,
          name: spot['name'] as String,
          type: '2-wheeler',
          x: spot['x'] as double,
          y: spot['y'] as double,
          isOccupied: false,
          createdAt: now,
          updatedAt: now,
        );
        
        await _firestore
            .collection('parking_spots')
            .doc(parkingSpot.id)
            .set(parkingSpot.toMap());
      } else {
        // Update existing spot position if coordinates changed
        final existingDoc = existingSpots.docs.firstWhere((doc) => doc.data()['name'] == spot['name']);
        final existingX = existingDoc.data()['x'] as double;
        final existingY = existingDoc.data()['y'] as double;
        final newX = spot['x'] as double;
        final newY = spot['y'] as double;
        
        if (existingX != newX || existingY != newY) {
          await _firestore.collection('parking_spots').doc(existingDoc.id).update({
            'x': newX,
            'y': newY,
            'updatedAt': now.toIso8601String(),
          });
        }
      }
    }

    // Add or update H* spots along the horizontal road
    for (var spot in twoWheelerSpotsHorizontal) {
      if (!existingNames.contains(spot['name'])) {
        final parkingSpot = ParkingSpot(
          id: _firestore.collection('parking_spots').doc().id,
          name: spot['name'] as String,
          type: '2-wheeler',
          x: spot['x'] as double,
          y: spot['y'] as double,
          isOccupied: false,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('parking_spots')
            .doc(parkingSpot.id)
            .set(parkingSpot.toMap());
      } else {
        final existingDoc = existingSpots.docs.firstWhere((doc) => doc.data()['name'] == spot['name']);
        final existingX = existingDoc.data()['x'] as double;
        final existingY = existingDoc.data()['y'] as double;
        final newX = spot['x'] as double;
        final newY = spot['y'] as double;

        if (existingX != newX || existingY != newY) {
          await _firestore.collection('parking_spots').doc(existingDoc.id).update({
            'x': newX,
            'y': newY,
            'updatedAt': now.toIso8601String(),
          });
        }
      }
    }
  }


  Future<void> _createInitialParkingSpots() async {
    final now = DateTime.now();
    
    // 4-wheeler parking spots - Left side of road (15 spots, smaller spacing)
    final fourWheelerLeftSpots = [
      {'name': 'A1', 'x': 0.35, 'y': 0.05},
      {'name': 'A2', 'x': 0.35, 'y': 0.09},
      {'name': 'A3', 'x': 0.35, 'y': 0.13},
      {'name': 'A4', 'x': 0.35, 'y': 0.17},
      {'name': 'A5', 'x': 0.35, 'y': 0.21},
      {'name': 'A6', 'x': 0.35, 'y': 0.25},
      {'name': 'A7', 'x': 0.35, 'y': 0.29},
      {'name': 'A8', 'x': 0.35, 'y': 0.33},
      {'name': 'A9', 'x': 0.35, 'y': 0.37},
      {'name': 'A10', 'x': 0.35, 'y': 0.41},
      {'name': 'A11', 'x': 0.35, 'y': 0.45},
      {'name': 'A12', 'x': 0.35, 'y': 0.49},
      {'name': 'A13', 'x': 0.35, 'y': 0.53},
      {'name': 'A14', 'x': 0.35, 'y': 0.57},
      {'name': 'A15', 'x': 0.35, 'y': 0.61},
    ];

    // 4-wheeler parking spots - Right side of road (15 spots, smaller spacing)
    final fourWheelerRightSpots = [
      {'name': 'B1', 'x': 0.65, 'y': 0.05},
      {'name': 'B2', 'x': 0.65, 'y': 0.09},
      {'name': 'B3', 'x': 0.65, 'y': 0.13},
      {'name': 'B4', 'x': 0.65, 'y': 0.17},
      {'name': 'B5', 'x': 0.65, 'y': 0.21},
      {'name': 'B6', 'x': 0.65, 'y': 0.25},
      {'name': 'B7', 'x': 0.65, 'y': 0.29},
      {'name': 'B8', 'x': 0.65, 'y': 0.33},
      {'name': 'B9', 'x': 0.65, 'y': 0.37},
      {'name': 'B10', 'x': 0.65, 'y': 0.41},
      {'name': 'B11', 'x': 0.65, 'y': 0.45},
      {'name': 'B12', 'x': 0.65, 'y': 0.49},
      {'name': 'B13', 'x': 0.65, 'y': 0.53},
      {'name': 'B14', 'x': 0.65, 'y': 0.57},
      {'name': 'B15', 'x': 0.65, 'y': 0.61},
    ];

    // 2-wheeler parking spots - On either side of the passage
    final twoWheelerSpotsCompEne = [
      // Left side of passage - 8 spots
      {'name': 'E1', 'x': 0.20, 'y': 0.79},
      {'name': 'E2', 'x': 0.20, 'y': 0.81},
      {'name': 'E3', 'x': 0.20, 'y': 0.83},
      {'name': 'E4', 'x': 0.20, 'y': 0.85},
      {'name': 'E5', 'x': 0.20, 'y': 0.87},
      {'name': 'E6', 'x': 0.20, 'y': 0.89},
      {'name': 'E7', 'x': 0.20, 'y': 0.91},
      {'name': 'E8', 'x': 0.20, 'y': 0.93},
      {'name': 'E9', 'x': 0.20, 'y': 0.95},
      {'name': 'E10', 'x': 0.20, 'y': 0.97},
      {'name': 'E11', 'x': 0.20, 'y': 0.99},
      // Right side of passage - 8 spots
      {'name': 'E12', 'x': 0.354, 'y': 0.82},
      {'name': 'E13', 'x': 0.354, 'y': 0.84},
      {'name': 'E14', 'x': 0.354, 'y': 0.86},
      {'name': 'E15', 'x': 0.354, 'y': 0.88},
      {'name': 'E16', 'x': 0.354, 'y': 0.90},
      {'name': 'E17', 'x': 0.354, 'y': 0.92},
      {'name': 'E18', 'x': 0.354, 'y': 0.94},
      {'name': 'E19', 'x': 0.354, 'y': 0.96},
      {'name': 'E20', 'x': 0.354, 'y': 0.98},
    ];

    // 2-wheeler vertical spots placed along the horizontal road (centered on the road)
    final twoWheelerSpotsHorizontal = [
      {'name': 'H1', 'x': 0.20, 'y': 0.72},
      {'name': 'H2', 'x': 0.23, 'y': 0.72},
      {'name': 'H3', 'x': 0.26, 'y': 0.72},
      {'name': 'H4', 'x': 0.29, 'y': 0.72},
      {'name': 'H5', 'x': 0.32, 'y': 0.72},
      {'name': 'H6', 'x': 0.35, 'y': 0.72},
      {'name': 'H7', 'x': 0.38, 'y': 0.72},
      {'name': 'H8', 'x': 0.41, 'y': 0.72},
      {'name': 'H9', 'x': 0.44, 'y': 0.72},
      {'name': 'H10', 'x': 0.74, 'y': 0.72},
      {'name': 'H11', 'x': 0.77, 'y': 0.72},
      {'name': 'H12', 'x': 0.80, 'y': 0.72},
      {'name': 'H13', 'x': 0.83, 'y': 0.72},
    ];

    // Create 4-wheeler spots - Left side
    for (var spot in fourWheelerLeftSpots) {
      final parkingSpot = ParkingSpot(
        id: _firestore.collection('parking_spots').doc().id,
        name: spot['name'] as String,
        type: '4-wheeler',
        x: spot['x'] as double,
        y: spot['y'] as double,
        isOccupied: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore
          .collection('parking_spots')
          .doc(parkingSpot.id)
          .set(parkingSpot.toMap());
    }

    // Create 4-wheeler spots - Right side
    for (var spot in fourWheelerRightSpots) {
      final parkingSpot = ParkingSpot(
        id: _firestore.collection('parking_spots').doc().id,
        name: spot['name'] as String,
        type: '4-wheeler',
        x: spot['x'] as double,
        y: spot['y'] as double,
        isOccupied: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore
          .collection('parking_spots')
          .doc(parkingSpot.id)
          .set(parkingSpot.toMap());
    }

    // Create 2-wheeler spots along Comp/Ene building (vertical)
    for (var spot in twoWheelerSpotsCompEne) {
      final parkingSpot = ParkingSpot(
        id: _firestore.collection('parking_spots').doc().id,
        name: spot['name'] as String,
        type: '2-wheeler',
        x: spot['x'] as double,
        y: spot['y'] as double,
        isOccupied: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestore
          .collection('parking_spots')
          .doc(parkingSpot.id)
          .set(parkingSpot.toMap());
    }

    // Create 2-wheeler vertical spots along horizontal road
    for (var spot in twoWheelerSpotsHorizontal) {
      final parkingSpot = ParkingSpot(
        id: _firestore.collection('parking_spots').doc().id,
        name: spot['name'] as String,
        type: '2-wheeler',
        x: spot['x'] as double,
        y: spot['y'] as double,
        isOccupied: false,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('parking_spots')
          .doc(parkingSpot.id)
          .set(parkingSpot.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Parking Map'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.green, 'Available'),
                      _buildLegendItem(Colors.red, 'Occupied'),
                      _buildLegendItem(Colors.blue, 'Your Spot'),
                    ],
                  ),
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
                    stream: _firestore
                        .collection('parking_spots')
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

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No parking spots available'),
                        );
                      }

                      final spots = snapshot.data!.docs
                          .map((doc) => ParkingSpot.fromMap(doc.data() as Map<String, dynamic>))
                          .toList();

                      // Fixed dimensions for the map
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
                                    // Horizontal road at top (perpendicular to main road)
                                    Positioned(
                                      left: 0,
                                      top: -20, // Extends above the map
                                      child: Container(
                                        width: 400.0,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade600,
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                    // Main road (vertical line in center)
                                    Positioned(
                                      left: 400.0 * 0.468 - 12,
                                      top: -40,
                                      child: Container(
                                        width: 50,
                                        height: 522, // 600 * 0.87
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade600,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    // Comp/Ene Building at bottom left
                                    Positioned(
                                      left: -14.8, // 400 * -0.037
                                      bottom: 0,
                                      child: Container(
                                        width: 80, // 400 * 0.2
                                        height: 180, // 600 * 0.30
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
                                    // Computer Department building at bottom center
                                    Positioned(
                                      left: 158, // 400 * 0.395
                                      bottom: 0,
                                      child: Container(
                                        width: 120, // 400 * 0.30
                                        height: 120, // 600 * 0.20
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade400,
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
                                    // Mech Building at bottom right
                                    Positioned(
                                      left: 340, // 400 * 0.85
                                      bottom: 0,
                                      child: Container(
                                        width: 80, // 400 * 0.2
                                        height: 180, // 600 * 0.30
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
                                    // Horizontal road connecting Comp/Ene and Mech buildings
                                    Positioned(
                                      left: 64, // 400 * 0.16
                                      bottom: 126, // 600 * 0.21
                                      child: Container(
                                        width: 276, // 400 * 0.69
                                        height: 33,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade600,
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                    // Vertical road (passage) going down from Comp/Ene building
                                    Positioned(
                                      left: 106, // 400 * 0.265
                                      top: 450, // 600 * 0.75
                                      child: Container(
                                        width: 20,
                                        height: 180, // 600 * 0.3
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
                              ...spots.map((spot) => _buildParkingSpotFixed(spot)),
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
        ),
      ),
      floatingActionButton: null,
    );
  }

  void _zoomIn() {
    final Matrix4 currentMatrix = _transformationController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    
    if (currentScale < 3.0) {
      final double newScale = (currentScale * 1.2).clamp(1.0, 3.0);
      final Matrix4 newMatrix = Matrix4.identity()..scale(newScale);
      _transformationController.value = newMatrix;
    }
  }

  void _zoomOut() {
    final Matrix4 currentMatrix = _transformationController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    
    if (currentScale > 1.0) {
      final double newScale = (currentScale / 1.2).clamp(1.0, 3.0);
      final Matrix4 newMatrix = Matrix4.identity()..scale(newScale);
      _transformationController.value = newMatrix;
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
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

  Widget _buildParkingSpotFixed(ParkingSpot spot) {
    // Determine spot color based on occupancy and ownership
    Color spotColor;
    if (!spot.isOccupied) {
      spotColor = Colors.green; // Available
    } else if (spot.occupiedBy == _auth.currentUser?.uid) {
      spotColor = Colors.blue; // User's own spot
    } else {
      spotColor = Colors.red; // Occupied by others
    }

    // Fixed dimensions: 400x600
    const double mapWidth = 400.0;
    const double mapHeight = 600.0;
    
    // Use smaller size for 2-wheelers; H* 2-wheeler spots are vertical
    final bool isTwoWheeler = spot.type == '2-wheeler';
    final bool isVerticalTwoWheeler = isTwoWheeler && spot.name.toUpperCase().startsWith('H');
    final double spotWidth = isTwoWheeler ? (isVerticalTwoWheeler ? 10.0 : 30.0) : 45.0;
    final double spotHeight = isTwoWheeler ? (isVerticalTwoWheeler ? 26.0 : 10.0) : 25.0;
    
    // Calculate spot position using fixed coordinates
    final double spotX = (spot.x * mapWidth) - (spotWidth / 2);
    final double spotY = (spot.y * mapHeight) - (spotHeight / 2);

    return Positioned(
      left: spotX,
      top: spotY,
      child: GestureDetector(
        onTap: () => _showParkingConfirmation(spot),
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

  void _showParkingConfirmation(ParkingSpot spot) {
    if (widget.isGuest) {
      _showGuestParkingDialog();
      return;
    }
    
    if (spot.isOccupied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This parking spot is already occupied'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user already has an active parking spot
    _checkExistingParking(spot);
  }

  void _showGuestParkingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to park your vehicle. Guest users can only view available parking spots.'),
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

  Future<void> _checkExistingParking(ParkingSpot spot) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

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

      // If no existing parking, show confirmation dialog
      _showParkingDialog(spot);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking existing parking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showParkingDialog(ParkingSpot spot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Parking'),
        content: Text('Do you want to park at spot ${spot.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SelectVehicleForParkingScreen(spot: spot),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Select Vehicle'),
          ),
        ],
      ),
    );
  }

}
