import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart';

class PaymentLogsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("My Payments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('userId', isEqualTo: user!.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var paymentsDocs = snapshot.data!.docs;

          if (paymentsDocs.isEmpty)
            return Center(child: Text("No payments found."));

          return ListView.builder(
            itemCount: paymentsDocs.length,
            itemBuilder: (context, index) {
              var data = paymentsDocs[index].data() as Map<String, dynamic>;
              var payment = PaymentModel.fromMap(data);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(payment.planName),
                  subtitle: Text("Txn ID: ${payment.transactionId}"),
                  trailing: Text(
                    "₹${payment.amount.toStringAsFixed(2)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
