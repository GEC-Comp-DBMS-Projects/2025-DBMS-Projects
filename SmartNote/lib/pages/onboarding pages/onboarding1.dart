import 'package:flutter/material.dart';
import 'package:note_organiser/app_theme.dart';
import 'dart:math' as math;

import 'package:note_organiser/pages/onboarding%20pages/onboarding2.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  Onboarding1State createState() => Onboarding1State();
}

class Onboarding1State extends State<Onboarding1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
           
            Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildDiamondImage('assets/book1.png', -110, -60),
                    _buildDiamondImage('assets/book2.png', -30, -130),
                    _buildDiamondImage('assets/book3.png', 80, -85),
                    _buildDiamondImage('assets/book4.png', -80, 60),
                    _buildDiamondImage('assets/book5.png', 0, -10),
                    _buildDiamondImage('assets/book6.png', 120, 20),
                    _buildDiamondImage('assets/book7.png', 40, 100),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "SMART-NOTE\nHERE TO HELP YOU MANAGE YOUR\n NOTES",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding2(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Let's Go",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamondImage(String asset, double dx, double dy) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: math.pi / 4, // 45 degrees
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Image.asset(
              asset,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
