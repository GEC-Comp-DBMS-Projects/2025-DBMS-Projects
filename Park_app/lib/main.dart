import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'wrapper_screen.dart';
import 'vehicle_setup_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'vehicles_screen.dart';
import 'main_navigation_wrapper.dart';
import 'guest_entry_screen.dart';
import 'admin_login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      initialRoute: '/',
      routes: {
        '/': (_) => const WrapperScreen(),
        '/home': (_) => const MainNavigationWrapper(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/guest': (_) => const GuestEntryScreen(),
        '/admin-login': (_) => const AdminLoginScreen(),
        '/vehicle-setup': (_) => const VehicleSetupScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/vehicles': (_) => const VehiclesScreen(),
      },
    );
  }
}