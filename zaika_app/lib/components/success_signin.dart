import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInCompletePage extends StatelessWidget {
  const SignInCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Guest";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top half: image
          // Top half: image with circular edges
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(
                16.0,
              ), // optional padding around the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  20,
                ), // circular/rounded edges
                child: Image.asset(
                  'assets/images/success.jpeg',
                  width: 375,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // width: 370,

          //                 fit: BoxFit.cover,
          // Bottom half: text + button
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in completed successfully',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Directly navigate to DashboardPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DashboardPage(userName: userName),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E548E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
