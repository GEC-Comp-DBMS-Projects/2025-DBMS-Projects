import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/authchecker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CrowdrApp());
}

class CrowdrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crowdr.',
        theme: ThemeData(useMaterial3: true),
        home: const AuthScreen(), // ✅ i gave up with life
      ),
    );
  }
}
