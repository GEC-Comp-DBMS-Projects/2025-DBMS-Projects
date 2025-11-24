import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';
import '../auth/login_screen.dart'; // 👈 Import the new login UI

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('crowdr')
          .doc('users')
          .collection(user.uid)
          .doc('profile')
          .get();

      String userRole = '';
      if (doc.exists) userRole = doc['role'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(uid: user.uid, role: userRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoginPage(); // 👈 Use the new styled login UI
  }
}
