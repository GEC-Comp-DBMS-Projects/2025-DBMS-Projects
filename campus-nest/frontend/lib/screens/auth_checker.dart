import 'package:flutter/material.dart';
import 'package:frontend/admin/admin_profile.dart';
import 'package:frontend/tpo_screens/tpo_dash.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/recruiter_screens/recruiter_dash.dart';
import 'package:frontend/student_screens/stud_dash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  void _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role') ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return;
       
       if (token != null) {
         if (role == 'admin') {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => AdminProfilePage()),
           );
         } else if (role == 'student') {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => StudentDashboardScreen()),
           );
         } else if (role == 'tpo') {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => TPODashboardScreen()),
           );
         } else if (role == 'rec') {
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => RecruiterDashboardScreen()),
           );
         }
       } else {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const LoginScreen()),
         );
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
