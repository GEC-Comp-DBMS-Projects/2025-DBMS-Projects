import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kart_app/controllers/auth_service.dart';
import 'package:kart_app/providers/cart_provider.dart';
import 'package:kart_app/providers/user_provider.dart';
import 'package:kart_app/services/order_status_listener.dart';
import 'package:kart_app/views/cart_page.dart';
import 'package:kart_app/views/checkout_page.dart';
import 'package:kart_app/views/home_nav.dart';
import 'package:kart_app/views/login.dart';
import 'package:kart_app/views/onboarding.dart';
import 'package:kart_app/views/orders_page.dart';
import 'package:kart_app/views/signup.dart';
import 'package:kart_app/views/specific_products.dart';
import 'package:kart_app/views/view_product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

  // Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Show notification even when in background
  final data = message.data;
  if (data['type'] == 'order_status' && data['order_id'] != null) {
    await OrderStatusListener().initialize();
    await OrderStatusListener().showStatusChangeNotification(
      orderId: data['order_id'],
      newStatus: data['new_status'] ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Firebase Messaging
  final messaging = FirebaseMessaging.instance;
  
  // Request permission for notifications
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Handle messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final data = message.data;
    if (data['type'] == 'order_status' && data['order_id'] != null) {
      await OrderStatusListener().initialize();
      await OrderStatusListener().showStatusChangeNotification(
        orderId: data['order_id'],
        newStatus: data['new_status'] ?? '',
      );
    }
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => const CheckUser(),
          "/login": (context) => const LoginPage(),
          "/signup": (context) => const SignupPage(),
          "/home": (context) => const HomeNav(),
          '/specific': (context) => const SpecificProducts(),
          '/view_product': (context) => const ViewProduct(),
          "/cart": (context) => const CartPage(),
          "/onboarding": (context) => const OnboardingPage(),
          "/checkout": (context) => const CheckoutPage(),
          "/orders": (context) => const OrdersPage(),
        },
      ),
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      final bool isLoggedIn = await AuthService().isLoggedIn();
      if (isLoggedIn) {
        // Initialize notifications first
        await OrderStatusListener().initialize();
        
        // Start listening to order changes
        final userId = await AuthService().getCurrentUserId();
        print('Current user ID: $userId'); // Debug print
        
        if (userId != null) {
          await OrderStatusListener().startListening(userId);
          print('Started listening to order updates for user: $userId'); // Debug print
        } else {
          print('No user ID available'); // Debug print
        }
        
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } else {
      await prefs.setBool('hasSeenOnboarding', true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/onboarding");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}