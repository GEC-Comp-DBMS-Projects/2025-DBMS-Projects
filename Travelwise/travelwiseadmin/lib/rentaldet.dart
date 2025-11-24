import 'package:flutter/material.dart';
import 'confirm1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vehicleavail.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seaterController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();

  String _selectedDriveType = 'Manual';
  String _selectedVehicleType = 'Car';
  List<String> features = [];

  bool _isSubmitting = false;

  void _addFeature() {
    final text = _featureController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        features.add(text);
        _featureController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      features.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (features.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one feature')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final vehiclesCollection = FirebaseFirestore.instance.collection(
        'vehicles',
      );

      // Fetch existing IDs to find the max
      final snapshot = await vehiclesCollection.get();
      final existingIds = snapshot.docs
          .map((doc) => int.tryParse(doc.id))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      final maxId = existingIds.isEmpty
          ? 0
          : existingIds.reduce((a, b) => a > b ? a : b);
      final newId = (maxId + 1).toString(); // new doc ID and vehicleid

      final user = FirebaseAuth.instance.currentUser;

      final vehicleData = {
        'uid': user?.uid ?? 'unknown',
        'vehicleid': int.parse(newId),
        'carname': _carNameController.text.trim(),
        'drivetype': _selectedDriveType,
        'features': features,
        'number': int.parse(_numberController.text.trim()),
        'pickup': _pickupController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'seater': int.parse(_seaterController.text.trim()),
        'vehicletype': _selectedVehicleType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await vehiclesCollection.doc(newId).set(vehicleData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle added successfully with ID $newId')),
      );
      syncVehicleAvailabilityForVehicle(vehicleDocId: newId, days: 60);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessPage()),
      );

      _formKey.currentState!.reset();
      setState(() {
        features.clear();
        _selectedDriveType = 'Manual';
        _selectedVehicleType = 'Car';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add vehicle: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 43, 178),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Car Name
                    TextFormField(
                      controller: _carNameController,
                      decoration: _inputDecoration('Car Name'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter car name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Drive Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedDriveType,
                      decoration: _inputDecoration('Drive Type'),
                      items: ['Manual', 'Automatic']
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDriveType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: _inputDecoration('Vehicle Type'),
                      items: ['Car', 'Scooter']
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVehicleType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pickup Location
                    TextFormField(
                      controller: _pickupController,
                      decoration: _inputDecoration('Pickup Location'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter pickup location'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('Price'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seater
                    TextFormField(
                      controller: _seaterController,
                      decoration: _inputDecoration('Seater'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of seaters';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Number of Cars
                    TextFormField(
                      controller: _numberController,
                      decoration: _inputDecoration('Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Features
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _featureController,
                            decoration: _inputDecoration('Add Feature'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addFeature,
                          child: const Icon(Icons.add, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              28,
                              43,
                              178,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: List.generate(
                        features.length,
                        (index) => Chip(
                          label: Text(features[index]),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeFeature(index),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    Text('Please send your image to smitdalvi29@gmail.com/+918605692288',style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(200,50),
                        backgroundColor: const Color.fromARGB(255, 28, 43, 178),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Vehicle',
                        style: TextStyle(fontSize: 18,color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _carNameController.dispose();
    _pickupController.dispose();
    _priceController.dispose();
    _seaterController.dispose();
    _numberController.dispose();
    _featureController.dispose();
    super.dispose();
  }
}
