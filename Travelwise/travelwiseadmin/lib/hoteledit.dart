import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'roomavail.dart';

class RoomType {
  String id;
  String name;
  List<String> features;
  int rooms;
  int persons;
  double price;

  RoomType({
    required this.id,
    required this.name,
    required this.features,
    required this.rooms,
    required this.persons,
    required this.price,
  });

  factory RoomType.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RoomType(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      features: List<String>.from(data['Features'] as List<dynamic>? ?? []),
      rooms: (data['Rooms'] as int?) ?? 0,
      persons: (data['person'] as int?) ?? 0,
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as double?) ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'Features': features,
      'Rooms': rooms,
      'person': persons,
      'price': price,
    };
  }
}

class EditHotelPage extends StatefulWidget {
  final String hotelId;

  const EditHotelPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<EditHotelPage> createState() => _EditHotelPageState();
}

class _EditHotelPageState extends State<EditHotelPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  List<String> _benefits = [];
  List<String> _inclusions = [];
  final TextEditingController _benefitController = TextEditingController();
  final TextEditingController _inclusionController = TextEditingController();

  List<RoomType> _roomTypes = [];
  final TextEditingController _newRoomTypeNameController =
      TextEditingController();
  final TextEditingController _roomCountController = TextEditingController();
  final TextEditingController _maxPersonController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();
  List<String> _roomFeatures = [];

  @override
  void initState() {
    super.initState();
    _loadHotelData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _benefitController.dispose();
    _inclusionController.dispose();
    _newRoomTypeNameController.dispose();
    _roomCountController.dispose();
    _maxPersonController.dispose();
    _roomPriceController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelData() async {
    try {
      final hotelRef = FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.hotelId);
      final hotelDoc = await hotelRef.get();
      if (!hotelDoc.exists) {
        setState(() {
          _error = 'Hotel not found.';
          _isLoading = false;
        });
        return;
      }
      final data = hotelDoc.data()!;
      _nameController.text = (data['Hotelname'] as String?) ?? '';
      _descriptionController.text = (data['description'] as String?) ?? '';
      _locationController.text = (data['location'] as String?) ?? '';
      _priceController.text = ((data['price'] as num?)?.toString() ?? '');
      _ratingController.text = ((data['rating'] as num?)?.toString() ?? '');

      _benefits = List<String>.from(data['benefits'] as List<dynamic>? ?? []);
      _inclusions = List<String>.from(
        data['inclusions'] as List<dynamic>? ?? [],
      );

      final roomTypesSnap = await hotelRef.collection('Roomtype').get();
      _roomTypes = roomTypesSnap.docs
          .map((doc) => RoomType.fromDoc(doc))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load hotel details: $e';
        _isLoading = false;
      });
    }
  }

  void _addBenefit() {
    final text = _benefitController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _benefits.add(text);
        _benefitController.clear();
      });
    }
  }

  void _removeBenefit(int index) {
    setState(() {
      _benefits.removeAt(index);
    });
  }

  void _addInclusion() {
    final text = _inclusionController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _inclusions.add(text);
        _inclusionController.clear();
      });
    }
  }

  void _removeInclusion(int index) {
    setState(() {
      _inclusions.removeAt(index);
    });
  }

  void _addRoomFeature() {
    final text = _featureController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _roomFeatures.add(text);
        _featureController.clear();
      });
    }
  }

  void _removeRoomFeature(int index) {
    setState(() {
      _roomFeatures.removeAt(index);
    });
  }

  void _addOrUpdateRoomType() {
    final name = _newRoomTypeNameController.text.trim();
    final rooms = int.tryParse(_roomCountController.text.trim());
    final persons = int.tryParse(_maxPersonController.text.trim());
    final price = double.tryParse(_roomPriceController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Room type name required')));
      return;
    }
    if (_roomFeatures.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one feature')));
      return;
    }
    if (rooms == null || rooms <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid rooms count')));
      return;
    }
    if (persons == null || persons <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid persons count')));
      return;
    }
    if (price == null || price < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid price')));
      return;
    }

    final existingIndex = _roomTypes.indexWhere((rt) => rt.id == name);
    final newRoomType = RoomType(
      id: name,
      name: name,
      features: List<String>.from(_roomFeatures),
      rooms: rooms,
      persons: persons,
      price: price,
    );

    setState(() {
      if (existingIndex >= 0) {
        _roomTypes[existingIndex] = newRoomType;
      } else {
        _roomTypes.add(newRoomType);
      }
      _newRoomTypeNameController.clear();
      _roomCountController.clear();
      _maxPersonController.clear();
      _roomPriceController.clear();
      _roomFeatures.clear();
    });
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final hotelRef = FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.hotelId);

      await hotelRef.update({
        'uid': user?.uid,
        'Hotelname': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'rating': double.tryParse(_ratingController.text.trim()) ?? 0.0,
        'benefits': _benefits,
        'inclusions': _inclusions,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final batch = FirebaseFirestore.instance.batch();
      final subCol = hotelRef.collection('Roomtype');
      final existingDocs = await subCol.get();

      final idsCurrent = _roomTypes.map((rt) => rt.id).toSet();
      for (var doc in existingDocs.docs) {
        if (!idsCurrent.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }
      for (var rt in _roomTypes) {
        final docRef = subCol.doc(rt.id);
        batch.set(docRef, rt.toMap());
      }

      await batch.commit();

      if (mounted) {
        await updateRoomAvailabilityForEditedHotel(widget.hotelId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving hotel: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildEditableList({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(items[i]),
                
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(i),
                ),
              );
            }).toList(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Add new $title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: onAdd, child: const Text('Add')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypesEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Types',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _newRoomTypeNameController,
                  decoration: _inputDecoration('Room Type Name'),
                ),
                const SizedBox(height: 8),
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
                      onPressed: _addRoomFeature,
                      child: const Text('Add'),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _roomFeatures.map((f) {
                    final idx = _roomFeatures.indexOf(f);
                    return Chip(
                      label: Text(f),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        _removeRoomFeature(idx);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _roomCountController,
                        decoration: _inputDecoration('Number of Rooms'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxPersonController,
                        decoration: _inputDecoration('Max Persons'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomPriceController,
                  decoration: _inputDecoration('Price'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addOrUpdateRoomType,
                  child: const Text('Add / Update Room Type'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._roomTypes.map((rt) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(rt.name),
              subtitle: Text(
                'Rooms: ${rt.rooms}, Persons: ${rt.persons}, Price: \$${rt.price.toStringAsFixed(2)}\nFeatures: ${rt.features.join(', ')}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _roomTypes.removeWhere((item) => item.id == rt.id);
                  });
                },
              ),
              onTap: () {
                _newRoomTypeNameController.text = rt.name;
                _roomFeatures = List<String>.from(rt.features);
                _roomCountController.text = rt.rooms.toString();
                _maxPersonController.text = rt.persons.toString();
                _roomPriceController.text = rt.price.toString();
                setState(() {});
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Hotel')),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hotel'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Hotel Name'),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter hotel name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildEditableList(
                      title: 'Benefits',
                      items: _benefits,
                      controller: _benefitController,
                      onAdd: _addBenefit,
                      onRemove: _removeBenefit,
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Description'),
                      maxLines: 3,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter description'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildEditableList(
                      title: 'Inclusions',
                      items: _inclusions,
                      controller: _inclusionController,
                      onAdd: _addInclusion,
                      onRemove: _removeInclusion,
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Location'),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter location'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('Price'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Enter price';
                        if (double.tryParse(val.trim()) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ratingController,
                      decoration: _inputDecoration('Rating (1‑5)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Enter rating';
                        final r = double.tryParse(val.trim());
                        if (r == null || r < 1 || r > 5)
                          return 'Rating must be 1‑5';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildRoomTypesEditor(),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveHotel,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Save Hotel',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
