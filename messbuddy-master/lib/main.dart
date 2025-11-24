import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔽 UPDATED ALL IMPORTS TO USE 'package:messbuddy/' PREFIX
import 'package:messbuddy/recent_activities_page.dart';
import 'package:messbuddy/splash_screen.dart';
import 'package:messbuddy/signup.dart';
import 'package:messbuddy/home_page.dart';
import 'package:messbuddy/menupage.dart';
import 'package:messbuddy/profile_settings_page.dart';
import 'package:messbuddy/book_meal_page.dart';
import 'package:messbuddy/feedback_page.dart';
import 'package:messbuddy/vendor_feedback_page.dart';
import 'package:messbuddy/vendor_dashboard.dart';
import 'package:messbuddy/subscription_page.dart';
import 'package:messbuddy/payment_logs_page.dart';
import 'package:messbuddy/attendance.dart';
import 'package:messbuddy/analytics.dart';

// 🟢 Awesome Notifications
import 'package:awesome_notifications/awesome_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(
    null, // default app icon
    [
      NotificationChannel(
        channelKey: 'meal_channel',
        channelName: 'Meal Reminders',
        channelDescription: 'Reminders for Breakfast, Lunch and Dinner',
        defaultColor: const Color(0xFF33D0A3),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );

  // Ask user for notification permission (first time only)
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Schedule daily notifications
  await scheduleDailyNotifications();

  runApp(const MyApp());
}

// 🔹 Schedule Breakfast, Lunch, Dinner (timezone-aware)
Future<void> scheduleDailyNotifications() async {
  final String tz = await AwesomeNotifications().getLocalTimeZoneIdentifier();

  // Breakfast 8:00 AM
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'meal_channel',
      title: 'Breakfast Reminder 🍳',
      body: 'Good morning! Time for a healthy breakfast!',
    ),
    schedule: NotificationCalendar(
      hour: 8,
      minute: 0,
      second: 0,
      repeats: true,
      timeZone: tz,
    ),
  );

  // Lunch 1:00 PM
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 2,
      channelKey: 'meal_channel',
      title: 'Lunch Reminder 🍛',
      body: 'It’s 1 PM! Don’t skip your lunch!',
    ),
    schedule: NotificationCalendar(
      hour: 13,
      minute: 0,
      second: 0,
      repeats: true,
      timeZone: tz,
    ),
  );

  // Dinner 8:00 PM
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 3,
      channelKey: 'meal_channel',
      title: 'Dinner Reminder 🍽️',
      body: 'Time for dinner! Eat well and stay healthy!',
    ),
    schedule: NotificationCalendar(
      hour: 20,
      minute: 0,
      second: 0,
      repeats: true,
      timeZone: tz,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessBuddy',

      // Start with splash screen
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthGate(),
        '/menu_page': (context) => const MenuPage(),
        '/profile_settings_page': (context) => const ProfileSettingsPage(),
        '/book_meal_page': (context) => const BookMealPage(),
        '/feedback_page': (context) => const FeedbackPage(),
        '/vendor_feedback_page': (context) => const VendorFeedbackPage(),

        // ✅ Subscription/payment pages
        '/subscription_page': (context) => SubscriptionPage(),
        '/payment_logs_page': (context) => PaymentLogsPage(),
        '/vendor_dashboard': (context) => const VendorHomePage(),
        '/analytics': (context) => const AnalyticsPage(),

        '/recent_activities_page': (context) => const RecentActivitiesPage(),
        
        // 🔽 ADDED THE NEW ROUTE (AND FIXED THE DUPLICATE KEY)
        '/attendance_page': (context) => const AttendancePage(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        // Other theme properties
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // User is logged in
          return HomePage();
        } else {
          // User not logged in → show signup/login page
          return const SignupPage();
        }
      },
    );
  }
}