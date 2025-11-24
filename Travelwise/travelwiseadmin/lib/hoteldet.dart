import 'package:flutter/material.dart';
import 'confirm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'roomavail.dart';

class AddHotelPage extends StatefulWidget {
  const AddHotelPage({super.key});

  @override
  State<AddHotelPage> createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  List<String> benefits = [];
  List<String> inclusions = [];

  final TextEditingController _benefitController = TextEditingController();
  final TextEditingController _inclusionController = TextEditingController();

  // Room Type related controllers and data
  List<RoomType> roomTypes = [];

  final TextEditingController _roomTypeNameController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();
  List<String> roomFeatures = [];

  final TextEditingController _roomCountController = TextEditingController();
  final TextEditingController _maxPersonController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _benefitController.dispose();
    _inclusionController.dispose();

    _roomTypeNameController.dispose();
    _featureController.dispose();
    _roomCountController.dispose();
    _maxPersonController.dispose();
    _roomPriceController.dispose();

    super.dispose();
  }

  void _addBenefit() {
    final text = _benefitController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        benefits.add(text);
        _benefitController.clear();
      });
    }
  }

  void _removeBenefit(int index) {
    setState(() {
      benefits.removeAt(index);
    });
  }

  void _addInclusion() {
    final text = _inclusionController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        inclusions.add(text);
        _inclusionController.clear();
      });
    }
  }

  void _removeInclusion(int index) {
    setState(() {
      inclusions.removeAt(index);
    });
  }

  void _addRoomFeature() {
    final text = _featureController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        roomFeatures.add(text);
        _featureController.clear();
      });
    }
  }

  void _removeRoomFeature(int index) {
    setState(() {
      roomFeatures.removeAt(index);
    });
  }

  void _addRoomType() {
    final name = _roomTypeNameController.text.trim();
    final rooms = int.tryParse(_roomCountController.text.trim());
    final person = int.tryParse(_maxPersonController.text.trim());
    final price = double.tryParse(_roomPriceController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room type name is required')),
      );
      return;
    }
    if (roomFeatures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one feature')),
      );
      return;
    }
    if (rooms == null || rooms <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of rooms')),
      );
      return;
    }
    if (person == null || person <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid max person count')),
      );
      return;
    }
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() {
      roomTypes.add(
        RoomType(
          name: name,
          Features: List.from(roomFeatures),
          rooms: rooms,
          person: person,
          price: price,
        ),
      );

      // Clear inputs for next room type
      _roomTypeNameController.clear();
      _roomCountController.clear();
      _maxPersonController.clear();
      _roomPriceController.clear();
      roomFeatures.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (benefits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one benefit')),
      );
      return;
    }

    if (inclusions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one inclusion')),
      );
      return;
    }

    if (roomTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one room type')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final hotelsCollection = FirebaseFirestore.instance.collection('Hotels');

      final snapshot = await hotelsCollection.get();

      final existingIds = snapshot.docs
          .map((doc) => int.tryParse(doc.id))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      final maxId = existingIds.isEmpty
          ? 0
          : existingIds.reduce((a, b) => a > b ? a : b);
      final newId = (maxId + 1).toString();

      final user = FirebaseAuth.instance.currentUser;

      final hotelData = {
        'uid': user?.uid ?? 'unknown',
        'Hotelname': _nameController.text.trim(),
        'imageUrl': 'https://via.placeholder.com/150',
        'Hotelid': int.parse(newId),
        'benefits': benefits,
        'description': _descriptionController.text.trim(),
        'inclusions': inclusions,
        'location': _locationController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'rating': double.tryParse(_ratingController.text.trim()) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await hotelsCollection.doc(newId).set(hotelData);

      final roomTypeCollection = hotelsCollection
          .doc(newId)
          .collection('Roomtype');

      for (final room in roomTypes) {
        await roomTypeCollection.doc(room.name).set({
          'Features': room.Features,
          'Rooms': room.rooms,
          'person': room.person,
          'price': room.price,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hotel and room types added successfully with ID $newId!',
          ),
        ),
      );

      await updateRoomAvailabilityForEditedHotel(newId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessPage()),
      );

      _formKey.currentState!.reset();
      setState(() {
        benefits.clear();
        inclusions.clear();
        roomTypes.clear();
        roomFeatures.clear();
      });
    } catch (e) {
      /*ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add hotel: $e')))*/;
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildDynamicList({
    required String title,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> items,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add $title',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 19, 19, 136),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              child: const Icon(Icons.add,color: Colors.white,),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(
            items.length,
            (index) => Chip(
              label: Text(items[index]),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => onRemove(index),
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRoomTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Types',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Room type name
        TextField(
          controller: _roomTypeNameController,
          decoration: _inputDecoration('Room Type Name'),
        ),
        const SizedBox(height: 12),

        // Features (dynamic array)
        Text(
          'Features',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _featureController,
                decoration: InputDecoration(
                  hintText: 'Add Feature',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addRoomFeature,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 28, 43, 178),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              child: const Icon(Icons.add,color: Colors.white,),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(
            roomFeatures.length,
            (index) => Chip(
              label: Text(roomFeatures[index]),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => _removeRoomFeature(index),
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Number of Rooms
        TextField(
          controller: _roomCountController,
          decoration: _inputDecoration('Number of Rooms'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // Max Persons
        TextField(
          controller: _maxPersonController,
          decoration: _inputDecoration('Max Persons'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // Price
        TextField(
          controller: _roomPriceController,
          decoration: _inputDecoration('Price'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        // Add Room Type button
        ElevatedButton(
          onPressed: _addRoomType,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            fixedSize: Size(200, 50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Add Room Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
          ),
        ),

        const SizedBox(height: 24),

        // Display added room types
        if (roomTypes.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Added Room Types:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...roomTypes.map(
                (room) => Card(
                  color:Colors.blue[50],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(room.name),
                    subtitle: Text(
                      'Rooms: ${room.rooms}, Max Person: ${room.person}, Price: \$${room.price.toStringAsFixed(2)}\nFeatures: ${room.Features.join(', ')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          roomTypes.remove(room);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
        title: const Text('Add Hotel',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 34, 31, 186),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hotel Name
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Hotel Name'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter hotel name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Benefits
                    _buildDynamicList(
                      title: 'Benefits',
                      controller: _benefitController,
                      onAdd: _addBenefit,
                      items: benefits,
                      onRemove: _removeBenefit,
                    ),

                    // Description (multiline)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Description'),
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Inclusions
                    _buildDynamicList(
                      title: 'Inclusions',
                      controller: _inclusionController,
                      onAdd: _addInclusion,
                      items: inclusions,
                      onRemove: _removeInclusion,
                    ),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Location'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('Price'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rating
                    TextFormField(
                      controller: _ratingController,
                      decoration: _inputDecoration('Rating (1-5)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter rating';
                        }
                        final rating = double.tryParse(val.trim());
                        if (rating == null || rating < 1 || rating > 5) {
                          return 'Rating must be between 1 and 5';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Room Types section
                    _buildRoomTypesSection(),

                    const SizedBox(height: 5),

                    Text('Please send your image to smitdalvi29@gmail.com/+918605692288',style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 32, 199),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Hotel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

class RoomType {
  final String name;
  final List<String> Features;
  final int rooms;
  final int person;
  final double price;

  RoomType({
    required this.name,
    required this.Features,
    required this.rooms,
    required this.person,
    required this.price,
  });
}
