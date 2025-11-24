import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin.dart';

class AdminSignupPage extends StatefulWidget {
  const AdminSignupPage({super.key});

  @override
  _AdminSignupPageState createState() => _AdminSignupPageState();
}

class _AdminSignupPageState extends State<AdminSignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

 Future<void> signUpAdmin() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all fields")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  try {
    // Try creating new user
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final uid = userCredential.user!.uid;

    // Add admin record
    await FirebaseFirestore.instance.collection('admins').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin account created!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminSignInPage()),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      // Email exists - sign in user silently to get UID
      try {
        UserCredential signInResult = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final uid = signInResult.user!.uid;

        // Add this user to admins collection
        await FirebaseFirestore.instance.collection('admins').doc(uid).set({
          'email': email,
          'addedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Existing user added as admin! Please sign in.")),
        );

        // Sign out after adding (optional)
        await FirebaseAuth.instance.signOut();

        // Redirect to sign-in page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminSignInPage()),
        );
      } on FirebaseAuthException catch (signInError) {
        // If password is wrong or sign-in fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add existing user as admin: ${signInError.message}')),
        );
      }
    } else {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters.';
          break;
        default:
          errorMessage = 'Signup failed. Try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/blue1.jpeg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTitle("Admin Signup"),
                  const SizedBox(height: 10),
                  _buildLabel("Email"),
                  _buildTextField(emailController, "Enter admin email", false),
                  const SizedBox(height: 8),
                  _buildLabel("Password"),
                  _buildTextField(passwordController, "Password", true),
                  const SizedBox(height: 8),
                  _buildLabel("Confirm Password"),
                  _buildTextField(confirmPasswordController, "Confirm Password", true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : signUpAdmin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 60),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      width: 320,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Container(
      width: 320,
      alignment: Alignment.centerLeft,
      child: Text(
        '  $label',
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool obscure) {
    return SizedBox(
      width: 320,
      height: 60,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 20),
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
