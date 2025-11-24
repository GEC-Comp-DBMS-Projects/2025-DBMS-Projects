import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'test123456');
  final _nameController = TextEditingController(text: 'Test User');
  
  String _statusMessage = 'Ready to test...';
  bool _isLoading = false;
  
  Map<String, dynamic>? _userData;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing sign up...';
    });

    try {
      String? error = await AuthService().signUp(
        _emailController.text,
        _passwordController.text,
        {
          'name': _nameController.text,
          'age': 25,
          'gender': 'Male',
          'weightGoal': 'Maintain',
        },
      );

      if (error == null) {
        setState(() {
          _statusMessage = '✓ Sign up successful! User created in Firebase Auth.';
        });
        print('✓ Auth successful');
      } else {
        setState(() {
          _statusMessage = '✗ Sign up failed: $error';
        });
        print('✗ Auth failed: $error');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '✗ Exception during sign up: $e';
      });
      print('✗ Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing sign in...';
    });

    try {
      String? error = await AuthService().signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (error == null) {
        setState(() {
          _statusMessage = '✓ Sign in successful! Connected to Firebase Auth.';
        });
        print('✓ Sign in successful');
        
        // Try to load user data
        await _loadUserData();
      } else {
        setState(() {
          _statusMessage = '✗ Sign in failed: $error';
        });
        print('✗ Sign in failed: $error');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '✗ Exception during sign in: $e';
      });
      print('✗ Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _statusMessage = 'Loading user data from Firestore...';
    });

    try {
      final data = await AuthService().getUserData();
      
      if (data != null) {
        setState(() {
          _userData = data;
          _statusMessage = '✓ User data loaded successfully from Firestore!';
        });
        print('✓ User data loaded: $data');
      } else {
        setState(() {
          _statusMessage = '⚠ User data is null (document might not exist)';
        });
        print('⚠ No user data found');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '✗ Error loading user data: $e';
      });
      print('✗ Error: $e');
    }
  }

  Future<void> _testUpdateUserData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing data update in Firestore...';
    });

    try {
      String? error = await AuthService().updateUserData({
        'email': _emailController.text,
        'name': 'Updated Test User',
        'age': 30,
        'gender': 'Female',
        'testField': 'This is a test update at ${DateTime.now()}',
      });

      if (error == null) {
        setState(() {
          _statusMessage = '✓ User data updated successfully in Firestore!';
        });
        print('✓ Update successful');
        
        // Reload data to verify
        await _loadUserData();
      } else {
        setState(() {
          _statusMessage = '✗ Update failed: $error';
        });
        print('✗ Update failed: $error');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '✗ Exception during update: $e';
      });
      print('✗ Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Color(0xFF007BFF),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Test Firebase Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Email Field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sign Up Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSignUp,
              icon: const Icon(Icons.person_add),
              label: const Text('Test Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Sign In Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Test Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Load User Data Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadUserData,
              icon: const Icon(Icons.download),
              label: const Text('Load User Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Update User Data Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testUpdateUserData,
              icon: const Icon(Icons.upload),
              label: const Text('Update User Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Status Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusMessage.contains('✗') 
                    ? Colors.red.withOpacity(0.1)
                    : _statusMessage.contains('✓')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _statusMessage.contains('✗')
                      ? Colors.red
                      : _statusMessage.contains('✓')
                          ? Colors.green
                          : Colors.grey,
                  width: 2,
                ),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains('✗')
                      ? Colors.red[900]
                      : _statusMessage.contains('✓')
                          ? Colors.green[900]
                          : Colors.grey[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Loading Indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            // Display User Data
            if (_userData != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Current User Data:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _userData!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

