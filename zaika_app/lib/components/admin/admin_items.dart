import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

const cloudName = 'dx02fsahn';
const uploadPreset = 'zaika_uploads';

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({super.key});

  @override
  State<AddFoodItemPage> createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Veg',
    'Non-Veg',
    'Drinks',
    'Dessert',
    'Egg',
  ];

  Future<void> _pickImage({required bool fromCamera}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(resStr);
      return data['secure_url'];
    }
    return null;
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate() || _imageFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and add a photo')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final imageUrl = await _uploadToCloudinary(_imageFile!);
    if (imageUrl == null) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Try again.')),
      );
      return;
    }

    final itemId = 'item_${DateTime.now().millisecondsSinceEpoch}';
    final menuItemData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory!,
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'preparation_time': int.tryParse(_prepTimeController.text.trim()) ?? 0,
      'image_url': imageUrl,
      'created_at': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('food_items').doc(itemId).set({
      'menuItems': {itemId: menuItemData},
    });

    setState(() => _isUploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item added successfully!')),
    );
    Navigator.pop(context);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8173C3)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF8173C3)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper for category icons
  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Veg':
        return const Icon(Icons.eco, color: Colors.green);
      case 'Non-Veg':
        return const Icon(Icons.set_meal, color: Colors.redAccent);
      case 'Drinks':
        return const Icon(Icons.local_drink, color: Colors.blueAccent);
      case 'Dessert':
        return const Icon(Icons.cake, color: Colors.pinkAccent);
      case 'Egg':
        return const Icon(Icons.egg, color: Colors.orangeAccent);
      default:
        return const Icon(Icons.fastfood, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FF),
      appBar: AppBar(
        title: const Text('Add Food Item'),
        backgroundColor: const Color(0xFF8173C3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(90),
                    border: Border.all(color: const Color(0xFF8173C3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 50, color: Color(0xFF8173C3))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Food Name'),
                  const SizedBox(height: 16),

                  // Modern Category Dropdown
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFF4F0FF),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8173C3)),
                        dropdownColor:Color(0xFFF4F0FF),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                _getCategoryIcon(category),
                                const SizedBox(width: 8),
                                Text(category),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (v) => v == null ? 'Please select a category' : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(_priceController, 'Price (₹)', isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(_prepTimeController, 'Preparation Time (minutes)', isNumber: true),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _saveFoodItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8173C3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Food Item',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          validator: (v) => v == null || v.isEmpty ? 'Please enter $label' : null,
        ),
      ),
    );
  }
}
