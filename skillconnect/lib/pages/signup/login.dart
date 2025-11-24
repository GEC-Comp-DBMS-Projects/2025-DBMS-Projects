import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // SkillConnect Color Scheme
  static const Color darkBlue = Color(0xFF304D6D); // Primary dark
  static const Color mediumBlue = Color(0xFF545E75); // Secondary dark
  static const Color lightBlue = Color(0xFF63ADF2); // Accent blue
  static const Color paleBlue = Color(0xFFA7CCED); // Light accent
  static const Color grayBlue = Color(0xFF82A0BC); // Medium accent

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Logo/Title
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      // --- MODIFIED: Replaced Icon with Image Logo ---
                      Container(
                        width: 80,
                        height: 80,
                        clipBehavior:
                            Clip.antiAlias, // This will clip the zoomed image
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Transform.scale(
                          scale: 1.9, // <-- Try values like 1.2, 1.5, etc.
                          child: Image.asset(
                            'assets/images/skillconnect_logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.build_circle,
                                size: 50,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                      // --- END MODIFICATION ---
                      SizedBox(height: 20),
                      Text(
                        'SkillConnect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Login To Continue!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Connect with skilled professionals in your area',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: paleBlue, fontSize: 16),
                ),
                SizedBox(height: 40),

                // Email Field
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: mediumBlue.withAlpha(76), // 0.3 opacity
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: grayBlue, width: 1),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      labelText: "Email Address",
                      labelStyle: TextStyle(color: paleBlue),
                      prefixIcon: Icon(Icons.email_outlined, color: lightBlue),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),

                // Password Field
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: mediumBlue.withAlpha(76), // 0.3 opacity
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: grayBlue, width: 1),
                  ),
                  child: TextFormField(
                    focusNode: _passwordFocusNode,
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(color: paleBlue),
                      prefixIcon: Icon(Icons.lock_outline, color: lightBlue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: grayBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Forgot password feature coming soon!'),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: lightBlue, fontSize: 14),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _performLogin();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // --- MODIFIED: Removed Divider and Google Sign In Button ---
                // The "OR" Divider Row and the Google Sign In Button
                // have been removed from here.
                // We keep one SizedBox to create space
                // before the "Sign Up" link.
                SizedBox(height: 40),
                // --- END MODIFICATION ---

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: paleBlue, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to sign up page
                        Navigator.pushNamed(context, '/signup/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: lightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // 2. Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      // If not in 'users', try 'serviceProvider'
      if (!userDoc.exists) {
        userDoc = await _firestore.collection('serviceProvider').doc(uid).get();
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? 'Customer';

        if (userType == 'Agent') {
          Navigator.pushReplacementNamed(context, '/agent/home');
        } else if (userType == 'Customer') {
          Navigator.pushReplacementNamed(context, '/customer/home');
        } else {
          Navigator.pushReplacementNamed(context, '/worker/home');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${userData['name'] ?? 'User'}!'),
            backgroundColor: lightBlue,
          ),
        );
      } else {
        _showErrorDialog(
          'Login Failed',
          'No user record found in Firestore. Please contact support.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found for this email';
      } else if (e.code == 'wrong-password') {
        message = 'Invalid password';
      }

      _showErrorDialog('Login Failed', message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog('Error', 'Something went wrong: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: TextStyle(color: mediumBlue)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: lightBlue, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
