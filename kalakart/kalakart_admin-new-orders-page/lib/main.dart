import 'package:ecommerce_admin_app/controllers/auth_service.dart';
import 'package:ecommerce_admin_app/firebase_options.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:ecommerce_admin_app/views/admin_home.dart';
import 'package:ecommerce_admin_app/views/categories_page.dart';
import 'package:ecommerce_admin_app/views/login.dart';
import 'package:ecommerce_admin_app/views/modify_product.dart';
import 'package:ecommerce_admin_app/views/modify_promo.dart';
import 'package:ecommerce_admin_app/views/orders_page.dart';
import 'package:ecommerce_admin_app/views/products_page.dart';
import 'package:ecommerce_admin_app/views/promo_banners_page.dart';
import 'package:ecommerce_admin_app/views/signup.dart';
import 'package:ecommerce_admin_app/views/view_product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'eccomerce',
        routes: {
          "/": (context) => CheckUser(),
          "/login": (context) => LoginPage(),
          "/signup": (context) => SingupPage(),
          "/home": (context) => AdminHome(),
          "/category" : (context) => CategoriesPage(),
          "/products": (context) => ProductsPage(),
          "/add_product": (context) => ModifyProduct(),
          "/view_product": (context) => ViewProduct(),
          "/promos": (context) => PromoBannersPage(),
          "/update_promo": (context) => ModifyPromo(),
            '/orders': (context) => OrdersPage(),
        
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
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


