import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderConfirmedPage extends StatelessWidget {
  final DocumentSnapshot order;

  const OrderConfirmedPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderData = order.data() as Map<String, dynamic>;
    final totalAmount = orderData['totalAmount'] ?? 0;

    const upiId = 'hoteladmin@upi';
    final upiUrl = "upi://pay?pa=$upiId&pn=Hotel%20Zaika&am=$totalAmount&cu=INR";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        backgroundColor: const Color(0xFF8173C3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Your order has been accepted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Amount: ₹$totalAmount',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Dynamic UPI QR
            QrImageView(
              data: upiUrl,
              gapless: true,
            ),

            const SizedBox(height: 20),
            Text(
              'UPI ID: $upiId\nScan this QR code with your UPI app to pay',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
