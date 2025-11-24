import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kart_app/models/cart_model.dart';

class DbService {
  // Get current user dynamically instead of storing it
  User? get user => FirebaseAuth.instance.currentUser;

  // USER DATA
  // save user data after creating new account
  Future saveUserData({required String name, required String email}) async {
    try {
      if (user == null) {
        print("Error: No user logged in");
        return;
      }
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "address": "",
        "phone": "",
      };
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .set(data);
      print("User data saved successfully for: ${user!.uid}");
    } catch (e) {
      print("error on saving user data: $e");
    }
  }

  // update other data in database
  Future updateUserData({required Map<String, dynamic> extraData}) async {
    if (user == null) {
      print("Error: No user logged in");
      return;
    }
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .update(extraData);
  }

  // read user current user data
  Stream<DocumentSnapshot> readUserData() {
    if (user == null) {
      print("Error: No user logged in, returning empty stream");
      return Stream.empty();
    }
    print("Reading user data for: ${user!.uid}");
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .snapshots();
  }

  // READ PROMOS AND BANNERS
  Stream<QuerySnapshot> readPromos() {
    return FirebaseFirestore.instance.collection("shop_promos").snapshots();
  }

  Stream<QuerySnapshot> readBanners() {
    return FirebaseFirestore.instance.collection("shop_banners").snapshots();
  }

  // DISCOUNTS
  // read discount coupons
  Stream<QuerySnapshot> readDiscounts() {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .orderBy("discount", descending: true)
        .snapshots();
  }

  // verify the coupon
  Future<QuerySnapshot> verifyDiscount({required String code}) {
    print("searching for code : $code");
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .where("code", isEqualTo: code)
        .get();
  }

  // CATEGORIES
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  // PRODUCTS
  // read products of specific categories
  Stream<QuerySnapshot> readProducts(String category) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where("category", isEqualTo: category.toLowerCase())
        .snapshots();
  }

  // search products by doc ids
  Stream<QuerySnapshot> searchProducts(List<String> docIds) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where(FieldPath.documentId, whereIn: docIds)
        .snapshots();
  }

  // reduce the count of products after purchase
  Future reduceQuantity(
      {required String productId, required int quantity}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(productId)
        .update({"quantity": FieldValue.increment(-quantity)});
  }

  // CART
  // display the user cart
  Stream<QuerySnapshot> readUserCart() {
    if (user == null) {
      print("Error: No user logged in");
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .snapshots();
  }

  // adding product to the cart
  Future addToCart({required CartModel cartData}) async {
    if (user == null) {
      print("Error: No user logged in");
      return;
    }
    try {
      // update
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("cart")
          .doc(cartData.productId)
          .update({
        "product_id": cartData.productId,
        "quantity": FieldValue.increment(1),
        "rental_days": cartData.rentalDays,
      });
    } on FirebaseException catch (e) {
      print("firebase exception : ${e.code}");
      if (e.code == "not-found") {
        // insert
        await FirebaseFirestore.instance
            .collection("shop_users")
            .doc(user!.uid)
            .collection("cart")
            .doc(cartData.productId)
            .set({
          "product_id": cartData.productId,
          "quantity": 1,
          "rental_days": cartData.rentalDays,
        });
      }
    }
  }

  // delete specific product from cart
  Future deleteItemFromCart({required String productId}) async {
    if (user == null) {
      print("Error: No user logged in");
      return;
    }
    try {
      // Get the cart item data before deleting (for logging if needed)
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("cart")
          .doc(productId)
          .get();

      // Delete the cart item
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("cart")
          .doc(productId)
          .delete();

      // Log deletion if needed
      print('Successfully deleted item: $productId from cart');
    } catch (e) {
      print('Error deleting item from cart: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // empty users cart
  Future emptyCart() async {
    if (user == null) {
      print("Error: No user logged in");
      return;
    }
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  }

  // decrease count of item
  Future decreaseCount({required String productId}) async {
    if (user == null) {
      print("Error: No user logged in");
      return;
    }
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .update({"quantity": FieldValue.increment(-1)});
  }

  // ORDERS
  // create a new order
  Future createOrder({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_orders").add(data);
  }

  // update the status of order
  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }

  // read the order data of specific user
  Stream<QuerySnapshot> readOrders() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .where("user_id", isEqualTo: currentUser.uid)
        .snapshots();
  }
}