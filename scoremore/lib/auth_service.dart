import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 SIGN UP — creates Firestore document
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // ✅ Create Firestore doc for this new user
      await usersRef.doc(userCredential.user!.uid).set({
        "name": name,
        "email": email.trim(),
        "created at": FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 🔹 LOGIN (no Firestore creation)
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 🔹 PASSWORD RESET
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // 🔹 GUEST SIGN-IN (local only — no Firestore)
  Future<void> signInAsGuestLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    await prefs.setString('guestName', 'Guest User');
    await prefs.setString('guestEmail', 'guest@example.com');
  }

  // 🔹 SIGN OUT
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      await prefs.remove('isGuest');
      await prefs.remove('guestName');
      await prefs.remove('guestEmail');
    } else {
      await _auth.signOut();
    }
  }

  // 🔹 HANDLE FIREBASE AUTH ERRORS
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Authentication error: ${e.message ?? "Unknown error"}';
    }
  }
}
