import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillconnect/pages/agent/edit_profile.dart';
import 'package:skillconnect/pages/agent/help.dart';
import 'package:skillconnect/pages/agent/home.dart';
import 'package:skillconnect/pages/agent/profile.dart';
import 'package:skillconnect/pages/agent/settings.dart';
import 'package:skillconnect/pages/customer/details.dart';
import 'package:skillconnect/pages/customer/help.dart';
import 'package:skillconnect/pages/customer/profile.dart';
import 'package:skillconnect/pages/customer/settings.dart';
import 'package:skillconnect/pages/worker/editprofile.dart';
import 'package:skillconnect/pages/worker/help.dart';
import 'package:skillconnect/pages/worker/home.dart';
import 'package:skillconnect/pages/worker/myjobs.dart';
import 'package:skillconnect/pages/worker/jobdetails.dart';
import 'package:skillconnect/pages/worker/profile.dart';
import 'firebase_options.dart';

import 'pages/signup/onboarding.dart';
import 'pages/signup/login.dart';
import 'pages/signup/signup.dart';
import 'pages/signup/csignup.dart';
import 'pages/signup/wsignup.dart';
import 'pages/customer/home.dart';
import 'pages/customer/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SkillConnectApp());
}

class SkillConnectApp extends StatelessWidget {
  const SkillConnectApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillConnect',
      theme: ThemeData(
        // SkillConnect Color Scheme
        primaryColor: Color(0xFF304D6D),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF304D6D),
          secondary: Color(0xFF63ADF2),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
      routes: {
        '/signup/onboarding': (context) => OnboardingScreen(),
        '/signup/login': (context) => LoginScreen(),
        '/signup/signup': (context) => UserTypeSelectionScreen(),
        '/signup/csignup': (context) => CustomerSignUpScreen(),
        '/signup/wsignup': (context) => AgentSignUpScreen(),
        '/customer/home': (context) => CustomerHomePage(),
        '/customer/services': (context) => SelectService(),
        '/customer/details': (context) =>
            JobDetailsPage(agentId: '', selectedService: ''),
        '/customer/profile': (context) => CustomerProfile(),
        '/customer/settings': (context) => CustomerSettingsPage(),
        '/customer/help': (context) => HelpSupportPage(),
        '/agent/home': (context) => AgentHomePage(),
        '/agent/profile': (context) => AgentProfilePage(),
        '/agent/settings': (context) => AgentSettingsPage(),
        '/agent/help': (context) => AgentHelpSupportPage(),
        '/agent/edit_profile': (context) => AgentEditProfilePage(),
        '/worker/home': (context) => WorkerHomePage(),
        '/worker/profile': (context) => WorkerProfilePage(),
        '/worker/help': (context) => WorkerHelpSupportPage(),
        '/worker/editprofile': (context) => WorkerEditProfilePage(),
        '/worker/myjobs': (context) => const MyJobsPage(),
        '/worker/jobdetails': (context) =>
            const WorkerJobDetailsPage(jobData: {}),
      },
    );
  }
}
