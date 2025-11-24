import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/data/globaldata.dart';
import 'package:note_organiser/pages/homepage%20pages/homepage.dart';
import 'package:note_organiser/pages/welcome.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          globalEmail = snapshot.data!.email!;
          return HomePage();
        }
        return WelcomeScreen();
      },
    );
  }
}
