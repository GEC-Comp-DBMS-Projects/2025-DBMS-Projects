import 'package:flutter/material.dart';
import 'package:frontend/admin/admin_dash.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/student_screens/stud_dash.dart';
import 'package:frontend/tpo_screens/tpo_dash.dart';
import 'package:frontend/recruiter_screens/recruiter_dash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  runApp(const CampusNestApp());
}

class CampusNestApp extends StatelessWidget {
  const CampusNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusNest',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    if (!mounted) return;

    if (token != null) {
      if (role == 'tpo') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TPODashboardScreen()),
        );
      } else if (role == 'rec') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RecruiterDashboardScreen()),
        );
      } else if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else if (role == 'student') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StudentDashboardScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA1B5B7),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Image.asset(
            'assets/images/campusnest_logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
