import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_organiser/auth/firebase_options.dart';
import 'package:note_organiser/auth/authchecker.dart';
import 'package:note_organiser/app_theme.dart';
import 'package:provider/provider.dart'; // Import provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MainApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  // 👇 Start in light mode by default
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
     
      themeMode: themeNotifier.themeMode,
      home: AuthChecker(),
    );
  }
}