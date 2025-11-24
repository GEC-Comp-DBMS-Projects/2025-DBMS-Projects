import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kart_app/controllers/db_service.dart';
import 'package:kart_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  String name = "User";
  String email = "";
  String address = "";
  String phone = "";

  UserProvider() {
    loadUserData();
  }

  // load user profile data
  void loadUserData() {
    print("🔄 UserProvider: Loading user data...");
    print("👤 Current user: ${FirebaseAuth.instance.currentUser?.uid}");

    _userSubscription?.cancel();
    _userSubscription = DbService().readUserData().listen(
      (snapshot) {
        print("📥 Got snapshot data: ${snapshot.data()}");
        if (snapshot.exists && snapshot.data() != null) {
          try {
            final UserModel data = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
            name = data.name;
            email = data.email;
            address = data.address;
            phone = data.phone;
            print("✅ User data loaded: $name, $email");
            notifyListeners();
          } catch (e) {
            print("❌ Error parsing user data: $e");
          }
        } else {
          print("❌ No user document found!");
        }
      },
      onError: (error) {
        print("❌ Error loading user data: $error");
      },
    );
  }

  void cancelProvider() {
    _userSubscription?.cancel();
    // Reset to default values
    name = "User";
    email = "";
    address = "";
    phone = "";
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}