import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String productId;
  int quantity;
  int rentalDays;
  double totalPrice;
  
  CartModel({
    required this.productId,
    required this.quantity,
    this.rentalDays = 1,
    this.totalPrice = 0,
  });

  // convert json to object model
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json["product_id"] ?? "",
      quantity: json["quantity"] ?? 0,
      rentalDays: json["rental_days"] ?? 1,
      totalPrice: (json["total_price"] ?? 0).toDouble(),
    );
  }

  // Convert List<QueryDocumentSnapshot> to List<CartModel>
  static List<CartModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => CartModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }
} 