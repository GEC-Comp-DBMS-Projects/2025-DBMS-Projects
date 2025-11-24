// splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'choose_user_widget.dart'; // Import ChooseUserWidget

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to ChooseUserWidget after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return; // safety check
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseUserWidget()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF625D9F), // Purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main Logo (scaled bigger)
            Transform.scale(
              scale: 2, // Increase actual image size
              child: Image.asset(
                "assets/images/zaika_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "Logo Missing ❌",
                    style: TextStyle(color: Colors.white),
                  );
                },
              ),
            ),

            const SizedBox(height: 40), // Increased space between logo and text image

            // Zaika Text Logo
            Image.asset(
              "assets/images/zaika_text_purple.png",
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "Text Logo Missing ❌",
                  style: TextStyle(color: Colors.white),
                );
              },
            ),

            const SizedBox(height: 20),

            // Tagline
            const Text(
              "DESI ZAIKA. MODERN TADKA",
              style: TextStyle(
                fontSize: 14,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
