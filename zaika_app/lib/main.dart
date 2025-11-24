import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zaika_app/components/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const ZaikaApp());
}

class ZaikaApp extends StatelessWidget {
  const ZaikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
