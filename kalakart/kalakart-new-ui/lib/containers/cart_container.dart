import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kart_app/controllers/db_service.dart';

class CartItemWidget extends StatefulWidget {
  final String productId;
  final String name;
  final double pricePerDay;
  final int maxQuantity;
  final VoidCallback onDelete;

  const CartItemWidget({
    super.key,
    required this.productId,
    required this.name,
    required this.pricePerDay,
    required this.maxQuantity,
    required this.onDelete,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int quantity;
  late int rentalDays;
  late double totalPrice;

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    final doc = await _firestore
        .collection('shop_users')
        .doc(userId)
        .collection('cart')
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      setState(() {
        quantity = doc.data()?['quantity'] ?? 1;
        rentalDays = doc.data()?['rental_days'] ?? 1;
        totalPrice = widget.pricePerDay * quantity * rentalDays;
      });
    } else {
      quantity = 1;
      rentalDays = 1;
      totalPrice = widget.pricePerDay;
    }
  }

  Future<void> deleteItem() async {
    try {
      await DbService().deleteItemFromCart(productId: widget.productId);
      widget.onDelete(); // Notify parent about deletion
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateFirestore() async {
    final data = {
      'product_id': widget.productId,
      'name': widget.name,
      'quantity': quantity,
      'rental_days': rentalDays,
      'price_per_day': widget.pricePerDay,
      'total_price': totalPrice,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('shop_users')  // Changed from 'carts' to match DbService
        .doc(userId)
        .collection('cart')        // Changed from 'items' to match DbService
        .doc(widget.productId)
        .set(data, SetOptions(merge: true));
  }

  void updatePrice() {
    setState(() {
      totalPrice = widget.pricePerDay * quantity * rentalDays;
    });
    updateFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.name, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Item'),
                        content: const Text('Are you sure you want to remove this item from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteItem();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity:"),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1
                          ? () {
                              quantity--;
                              updatePrice();
                            }
                          : null,
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: quantity < widget.maxQuantity
                          ? () {
                              quantity++;
                              updatePrice();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),

            // Rental Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Rental Days:"),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: rentalDays > 1
                          ? () {
                              rentalDays--;
                              updatePrice();
                            }
                          : null,
                    ),
                    Text(rentalDays.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        rentalDays++;
                        updatePrice();
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text("Total Price: ₹${totalPrice.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
