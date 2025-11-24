import 'package:flutter/material.dart';
import '2onboarding.dart';
import 'dart:async';

class StartScreen extends StatefulWidget {
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate to Onboarding after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/scmor2.png', fit: BoxFit.cover),
          // Slightly lower loading animation
          Positioned(
            bottom:
                MediaQuery.of(context).size.height *
                0.18, // Adjust this to move up/down
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ).withOpacity(0.75),
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
