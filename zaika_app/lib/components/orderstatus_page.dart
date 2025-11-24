import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_confirmed_page.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  bool _navigated = false; // ensure we navigate only once

  Stream<DocumentSnapshot?> _getLatestOrderStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
        backgroundColor: const Color(0xFF8173C3),
      ),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: _getLatestOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('You have not placed any orders yet.'),
            );
          }

          final order = snapshot.data!;
          final status = (order['status'] as String).trim().toLowerCase();

          if (status == 'pending') return _waitingForAdmin();

          if (status == 'accepted') {
            if (!_navigated) {
              _navigated = true;
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => OrderConfirmedPage(order: order)),
                );
              });
            }
            return const SizedBox.shrink();
          }

          if (status == 'paid') return _paidMessage();

          if (status == 'rejected') {
            return const Center(
              child: Text(
                'Your order was not accepted. Please try again later.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          return const Center(child: Text('Unknown order status.'));
        },
      ),
    );
  }

  Widget _waitingForAdmin() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.hourglass_top, size: 80, color: Colors.amber),
          SizedBox(height: 16),
          Text(
            'Waiting for admin to confirm your order...',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _paidMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.celebration, color: Colors.green, size: 80),
          SizedBox(height: 16),
          Text(
            'Payment successful! Your order is being prepared 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
