import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '2onboarding.dart'; // Your existing login/signup page
import '4home.dart'; // Assuming this is your ScoreMoreHome page (rename if needed)

// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ScoremoreApp());
}

class ScoremoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScoreMore',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

// Widget to decide which screen to show depending on auth state
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Listen to auth changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          // User not signed in → show auth page
          if (user == null) return OnboardingScreen();

          // User signed in → show home page
          return ScoreMoreHome();
        }

        // Loading spinner while waiting
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
