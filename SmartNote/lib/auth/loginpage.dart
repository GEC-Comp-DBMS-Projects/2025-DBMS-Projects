// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- ORIGINAL LOGIC: Preserved as requested ---
  bool signUp = false;
  final nameC = TextEditingController(),
      emailC = TextEditingController(),
      passwordC = TextEditingController();

  void signup() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailC.text.trim(),
          password: passwordC.text.trim(),
        )
        .then((onValue) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(emailC.text.trim())
          .set({'name': nameC.text.trim(), 'classes': []});
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void login() {
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailC.text.trim(),
      password: passwordC.text.trim(),
    );
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
  // --- END OF ORIGINAL LOGIC ---

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to style the UI
    final theme = Theme.of(context);

    return Scaffold(
      // Use theme color for the background
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: MediaQuery.of(context).size.width * 0.45,
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),

              Text(
                signUp ? "Create Account" : "Welcome Back",
                // Use headline text style from the theme
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                signUp
                    ? "Fill in your details to get started"
                    : "Sign in to your account",
                // Use body text style from the theme with a hint color
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Form Fields
              if (signUp) ...[
                Container(
                  decoration: BoxDecoration(
                    // Use theme color for card/field background
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    // Use theme color for the border
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextField(
                    controller: nameC,
                    style: theme.textTheme.bodyLarge, // Style for input text
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      // Use body text style from the theme for the hint
                      hintStyle: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: emailC,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    hintStyle: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.hintColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: passwordC,
                  obscureText: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.hintColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Primary Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: signUp ? signup : login,
                  style: TextButton.styleFrom(
                    // Use primary theme colors for the button
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    signUp ? "Create Account" : "Sign In",
                    // Use label text style from the theme
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle Text
              GestureDetector(
                onTap: () {
                  setState(() {
                    signUp = !signUp;
                  });
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    // Use body text style from the theme
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: signUp
                            ? "Already have an account? "
                            : "New to the app? ",
                      ),
                      TextSpan(
                        text: signUp ? "Sign In" : "Sign Up",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          // Use primary color for the interactive text
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}