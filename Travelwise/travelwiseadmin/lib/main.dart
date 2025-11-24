import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your screens
import 'signin.dart';       // Admin login page
//import 'admin_signup.dart';       // Admin signup page
//import 'admin_homepage.dart';     // Admin dashboard (after login)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set AdminSignInPage as the initial page
      home: const AdminSignInPage(),
      // Optional: Named routes if you want to use Navigator.pushNamed
      routes: {
        '/signin': (context) => const AdminSignInPage(),
        //'/signup': (context) => const AdminSignupPage(),
        //'/adminhome': (context) => const AdminHomepage(),
      },
    );
  }
}
