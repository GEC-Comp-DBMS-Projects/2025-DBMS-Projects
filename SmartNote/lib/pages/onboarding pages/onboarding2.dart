import 'package:flutter/material.dart';
import 'package:note_organiser/auth/loginpage.dart';
import 'package:note_organiser/app_theme.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 120),

          Center(
            child: Image.asset(
              'assets/logo.png',
              height: MediaQuery.of(context).size.width * 0.45,
              width: MediaQuery.of(context).size.width * 0.55,
            ),
          ),

          const SizedBox(height: 130),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Next",
                        // Using onPrimary color from the theme, which is designed for backgrounds of primary color.
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 18, height: 40),
                      // Icon color is also using the theme's onPrimary color.
                      Icon(Icons.arrow_right_alt, color: Theme.of(context).colorScheme.onPrimary),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Scan. Convert. Verify. Share.\nSummarize.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor, // Already using theme color
                  ),
                ),
                const SizedBox(height: 98),
                Text(
                  "Get a summary of your notes",
                  style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor), // Already using theme color
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}