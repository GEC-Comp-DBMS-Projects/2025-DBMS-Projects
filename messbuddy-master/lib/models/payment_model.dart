import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String userId;
  final String planName;
  final double amount;
  final String transactionId;
  final String status;
  final DateTime date;

  PaymentModel({
    required this.userId,
    required this.planName,
    required this.amount,
    required this.transactionId,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'planName': planName,
      'amount': amount,
      'transactionId': transactionId,
      'status': status,
      'date': date,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      userId: map['userId'],
      planName: map['planName'],
      amount: (map['amount'] as num).toDouble(),
      transactionId: map['transactionId'],
      status: map['status'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
