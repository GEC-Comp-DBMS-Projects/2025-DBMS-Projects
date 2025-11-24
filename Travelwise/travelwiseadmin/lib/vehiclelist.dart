import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vehicleedit.dart';
import 'vehiclebook.dart'; // BookingsByDatePage

class VehicleListPage extends StatelessWidget {
  const VehicleListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vehicles', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 15, 20, 149),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Please login to see your vehicles')),
      );
    }

    final vehiclesRef = FirebaseFirestore.instance
        .collection('vehicles')
        .where('uid', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 30, 14, 147),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/blue1.jpeg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          StreamBuilder<QuerySnapshot>(
            stream: vehiclesRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading vehicles: ${snapshot.error}'),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('No vehicles added yet.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data()! as Map<String, dynamic>;
                  final id = doc.id;
                  final vehicleId = data['vehicleid'];
                  final imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150';
                  final vehicleIdStr = vehicleId?.toString() ?? '1';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Vehicle Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.car_rental,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Vehicle Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                Text(
                                  data['carname'] ?? 'Unnamed Vehicle',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                                IconButton(
                                      alignment: Alignment.topRight,
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete Vehicle',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Vehicle'),
                                            content: Text(
                                                'Are you sure you want to permanently delete "${data['carname'] ?? 'this vehicle'}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            // 🔥 Delete the full document from Firestore
                                            await FirebaseFirestore.instance
                                                .collection('vehicles')
                                                .doc(id)
                                                .delete();

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Vehicle deleted successfully.'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error deleting vehicle: $e'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                ]
                              ),
                                const SizedBox(height: 6),
                                Text(
                                  'Type: ${data['vehicletype'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: ₹${data['price'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(height: 12),

                                // Buttons Row
                                Row(
                                  children: [
                                    // View Bookings Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BookingsByDatePage(
                                                vehicleDocId: vehicleIdStr,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('View Bookings'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Edit Button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditHotelVehiclePage(
                                                docId: id,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 20, 16, 130),
                                        ),
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
