import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final Map<String, dynamic> shippingAddress;
  final String paymentMethod;
  final String orderStatus;
  final int totalAmount;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.orderStatus,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: snapshot.id,
      userId: data['user_id'] ?? '',
      shippingAddress: Map<String, dynamic>.from(data['shipping_address'] ?? {}),
      paymentMethod: data['payment_method'] ?? 'cod',
      orderStatus: data['order_status'] ?? 'pending',
      totalAmount: data['total_amount'] ?? 0,
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        'order_status': orderStatus,
        'total_amount': totalAmount,
        'items': items,
        'created_at': Timestamp.fromDate(createdAt),
      };
}