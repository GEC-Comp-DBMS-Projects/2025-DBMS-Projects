import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  AddWorkerPageState createState() => AddWorkerPageState();
}

class AddWorkerPageState extends State<AddWorkerPage> {
  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color mediumBlue = Color(0xFF545E75);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color paleBlue = Color(0xFFA7CCED);
  static const Color grayBlue = Color(0xFF82A0BC);

  // --- Form State ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<String> _selectedServices = [];

  bool _isLoading = false;
  List<String> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _fetchAgentServices();
  }

  Future<void> _fetchAgentServices() async {
    try {
      final agentUid = FirebaseAuth.instance.currentUser?.uid;
      if (agentUid == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('agents')
          .doc(agentUid)
          .get();

      if (docSnapshot.exists && docSnapshot.data()!.containsKey('services')) {
        final List<dynamic> servicesData = docSnapshot['services'];
        setState(() {
          _availableServices = List<String>.from(servicesData);
        });
      } else {
        setState(() {
          _availableServices = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching agent services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createWorker() async {
    if (!_formKey.currentState!.validate() || _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and select at least one service.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'tempWorkerApp-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      UserCredential userCredential =
          await FirebaseAuth.instanceFor(
            app: tempApp,
          ).createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String newWorkerUid = userCredential.user!.uid;
      String? agentUid = FirebaseAuth.instance.currentUser?.uid;

      if (agentUid == null) throw Exception("Agent not logged in.");

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.set(
        FirebaseFirestore.instance.collection('users').doc(newWorkerUid),
        {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'contact': _contactController.text.trim(),
          'profilePicUrl': '',
          'userType': 'Worker',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      batch.set(
        FirebaseFirestore.instance.collection('workers').doc(newWorkerUid),
        {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'contact': _contactController.text.trim(),
          'agentId': agentUid,
          'availability': true,
          'rating': 0.0,
          'services': _selectedServices,
        },
      );

      await batch.commit();
      await tempApp.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating worker: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add New Worker',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _availableServices.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      _nameController,
                      'Full Name',
                      Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    _buildInputField(
                      _emailController,
                      'Email Address',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter email' : null,
                    ),
                    _buildInputField(
                      _contactController,
                      'Contact Number',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Enter contact' : null,
                    ),
                    _buildInputField(
                      _passwordController,
                      'Temporary Password',
                      Icons.lock_outline,
                      validator: (v) =>
                          v!.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildServicesSelection(),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createWorker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlue,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Create Worker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: paleBlue),
          prefixIcon: Icon(icon, color: lightBlue),
          filled: true,
          fillColor: mediumBlue.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: grayBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSelection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: mediumBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grayBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign Services',
            style: TextStyle(color: paleBlue, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableServices.map((service) {
              bool isSelected = _selectedServices.contains(service);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected
                      ? _selectedServices.remove(service)
                      : _selectedServices.add(service);
                }),
                child: Chip(
                  label: Text(
                    service,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isSelected ? mediumBlue : grayBlue,
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
