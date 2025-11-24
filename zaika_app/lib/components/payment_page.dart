import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentQRCodePage extends StatelessWidget {
  final String upiId;
  final double amount;

  const PaymentQRCodePage({
    super.key,
    required this.upiId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final upiUrl = "upi://pay?pa=$upiId&pn=Hotel%20Zaika&am=$amount&cu=INR";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay via UPI'),
        backgroundColor: const Color(0xFF8173C3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(data: upiUrl, size: 250.0, gapless: true),
            const SizedBox(height: 20),
            Text(
              "UPI ID: $upiId\nAmount: ₹$amount",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan this QR code with your UPI app to pay",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
