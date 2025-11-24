import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    List<String>? expertise,
    List<String>? interests,
  }) async {
    UserCredential? userCredential;
    String? userId;

    try {
      // Create user in Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      userId = userCredential.user!.uid;

      // DON'T send email verification here - it causes PigeonUserDetails error
      // User can send it manually from email verification screen
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Check if it's the PigeonUserDetails error
      String errorMsg = e.toString();
      if (errorMsg.contains('PigeonUserDetails') ||
          errorMsg.contains('List<Object?>')) {
        // Ignore this error - it's a known Firebase Auth bug
        // But we still have the userId, so continue to create Firestore doc
        userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw 'Registration failed: Could not get user ID';
        }
      } else {
        throw 'An error occurred during registration: $e';
      }
    }

    // CRITICAL: Create Firestore document AFTER auth errors are handled
    // This ensures the document gets created even if PigeonUserDetails error occurs
    try {
      final userModel = UserModel(
        uid: userId,
        email: email,
        name: name,
        role: role,
        expertise: expertise ?? [],
        interests: interests ?? [],
        createdAt: DateTime.now(),
        emailVerified: false,
      );

      print('🔥 Creating Firestore document for user: $userId');
      await _firestore.collection('users').doc(userId).set(userModel.toMap());
      print('✅ Firestore document created successfully!');
    } catch (e) {
      print('❌ FAILED to create Firestore document: $e');
      // Even if Firestore write fails, don't throw - user is registered in Auth
      // They can retry or we can handle this in the app
    }

    return userCredential;
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Check if it's the PigeonUserDetails error
      String errorMsg = e.toString();
      if (errorMsg.contains('PigeonUserDetails') ||
          errorMsg.contains('List<Object?>')) {
        // Ignore this error - it's a known Firebase Auth bug
        // User is actually signed in successfully
        return null; // Return null but don't throw
      }
      throw 'An error occurred during sign in: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'An error occurred during sign out: $e';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Failed to send verification email: $e';
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update password: $e';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Delete user document
        await _firestore.collection('users').doc(userId).delete();
        // Delete auth account
        await _auth.currentUser?.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user data: $e';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
