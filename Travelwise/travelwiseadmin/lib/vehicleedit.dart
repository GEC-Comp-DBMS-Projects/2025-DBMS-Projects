import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'vehicleavail.dart';

class EditHotelVehiclePage extends StatefulWidget {
  final String docId; // Firestore document ID for the vehicle/hotel

  const EditHotelVehiclePage({Key? key, required this.docId}) : super(key: key);

  @override
  State<EditHotelVehiclePage> createState() => _EditHotelVehiclePageState();
}

class _EditHotelVehiclePageState extends State<EditHotelVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seaterController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();

  String _selectedDriveType = 'manual';
  String _selectedVehicleType = 'Car';

  final List<String> _driveTypes = ['manual', 'automatic'];
  final List<String> _vehicleTypes = ['Car', 'Scooter', 'Truck', 'Van'];

  List<String> features = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  late String _uid;       // to keep uid from firestore doc
  late int _vehicleId;     // to keep vehicleid from firestore doc

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.docId)
          .get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document not found!')),
        );
        Navigator.pop(context);
        return;
      }

      final data = docSnapshot.data()!;

      setState(() {
        _carNameController.text = data['carname'] ?? '';
        _pickupController.text = data['pickup'] ?? '';
        _priceController.text = (data['price'] != null) ? data['price'].toString() : '';
        _seaterController.text = (data['seater'] != null) ? data['seater'].toString() : '';
        _numberController.text = (data['number'] != null) ? data['number'].toString() : '';
        _selectedDriveType = (data['drivetype'] ?? 'manual').toString().toLowerCase();
        _selectedVehicleType = data['vehicletype'] ?? 'Car';
        features = List<String>.from(data['features'] ?? []);
        _uid = (data['uid'] ?? '') as String;
        _vehicleId = (data['vehicleid'] ?? 0) as int;

        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
      Navigator.pop(context);
    }
  }

  void _addFeature() {
    final featureText = _featureController.text.trim();
    if (featureText.isNotEmpty) {
      setState(() {
        features.add(featureText);
      });
      _featureController.clear();
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
      final docRef = FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.docId);

      final updateData = {
        'carname': _carNameController.text.trim(),
        'drivetype': _selectedDriveType,
        'features': features,
        'number': int.parse(_numberController.text.trim()),
        'pickup': _pickupController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'seater': int.parse(_seaterController.text.trim()),
        'vehicletype': _selectedVehicleType,
        'uid': _uid,              // keep the original uid unchanged
        'vehicleid': _vehicleId,  // keep the original vehicleid unchanged
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully')),
      );

      syncVehicleAvailabilityForVehicle(vehicleDocId: widget.docId, days: 60);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Car Name
              TextFormField(
                controller: _carNameController,
                decoration: const InputDecoration(
                  labelText: 'Car Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter car name' : null,
              ),
              const SizedBox(height: 16),

              // Drive Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedDriveType,
                decoration: const InputDecoration(
                  labelText: 'Drive Type',
                  border: OutlineInputBorder(),
                ),
                items: _driveTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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

              // Vehicle Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                ),
                items: _vehicleTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
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

              // Pickup location
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter pickup location' : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter price';
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seater
              TextFormField(
                controller: _seaterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Seater',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter seater count';
                  final seats = int.tryParse(value);
                  if (seats == null || seats <= 0) return 'Enter valid seater count';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Number
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter number';
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue <= 0) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Features input + add button
              TextFormField(
                controller: _featureController,
                decoration: InputDecoration(
                  labelText: 'Add Feature',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addFeature,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Features list chips with delete
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.asMap().entries.map((entry) {
                  final index = entry.key;
                  final feature = entry.value;
                  return Chip(
                    label: Text(feature),
                    onDeleted: () => _removeFeature(index),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
