
import 'package:flutter/material.dart';
import 'package:kart_app/providers/cart_provider.dart';
import 'package:kart_app/views/cart_page.dart';
import 'package:kart_app/views/market_place.dart';
import 'package:kart_app/views/orders_page.dart';
import 'package:kart_app/views/profile.dart' as views;
import 'package:provider/provider.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const MarketPlace(),
    const OrdersPage(),
    const CartPage(),
    const views.ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex=value;
          });
        },
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.shop_outlined),
            label: 'MarketPlace',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, value, child) {
                if (value.carts.isNotEmpty) {
                  return Badge(
                    label: Text(value.carts.length.toString()),
                    child: const Icon(Icons.shopping_cart_outlined),
                    backgroundColor: Colors.green.shade400,
                  );
                }
                return const Icon(Icons.shopping_cart_outlined);
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/*
This is the home navbar of the app
 */