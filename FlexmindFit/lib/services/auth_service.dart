import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign up a new user
  Future<String?> signUp(String email, String password, Map<String, dynamic> userDetails) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user details in Firestore
      if (userCredential.user != null) {
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': email,
            'name': userDetails['name'] ?? '',
            'age': userDetails['age'] ?? 25,
            'gender': userDetails['gender'] ?? 'Male',
            'weightGoal': userDetails['weightGoal'] ?? 'Maintain',
            'workoutsCompleted': 0,
            'caloriesBurned': 0,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // Use merge to prevent overwriting if doc exists
          print('User data created successfully in Firestore');
        } catch (firestoreError) {
          print('Error creating user data in Firestore: $firestoreError');
          // Don't fail the entire registration if Firestore write fails
          // User can still sign in, and we'll handle missing data gracefully
        }
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An error occurred during registration: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign in an existing user
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user data exists, if not create default data
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        
        if (!doc.exists) {
          print('User document missing, creating default data...');
          await _createDefaultUserData();
        }
      } catch (e) {
        print('Error checking user data during sign in: $e');
        // Don't fail the sign-in if this check fails
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'An error occurred during sign in: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An error occurred: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser == null) {
      print('No current user signed in');
      return null;
    }
    
    try {
      print('Attempting to fetch user data from Firestore for user: ${_auth.currentUser!.uid}');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        print('✓ User document found in Firestore');
        return doc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist in Firestore. Creating default data...');
        // Create a default user document if it doesn't exist
        await _createDefaultUserData();
        // Try to get the data again
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        if (doc.exists) {
          print('✓ Default user data created and retrieved');
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } on FirebaseException catch (e) {
      print('✗ Firebase error getting user data: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        print('⚠️ Permission denied - Check Firestore security rules');
      } else if (e.code == 'unavailable') {
        print('⚠️ Firestore is unavailable - Check your internet connection');
      }
      return null;
    } catch (e) {
      print('✗ Error getting user data: $e');
      return null;
    }
  }

  // Create default user data if it doesn't exist
  Future<void> _createDefaultUserData() async {
    if (_auth.currentUser == null) return;
    
    try {
      print('Creating default user data for user: ${_auth.currentUser!.uid}');
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'email': _auth.currentUser!.email ?? '',
        'name': 'User',
        'age': 25,
        'gender': 'Male',
        'weightGoal': 'Maintain',
        'workoutsCompleted': 0,
        'caloriesBurned': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✓ Created default user data in Firestore');
    } on FirebaseException catch (e) {
      print('✗ Firebase error creating user data: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        print('⚠️ Permission denied - Check Firestore security rules');
      }
    } catch (e) {
      print('✗ Error creating default user data: $e');
    }
  }

  // Update user data in Firestore
  Future<String?> updateUserData(Map<String, dynamic> data) async {
    if (_auth.currentUser == null) return 'No user signed in';
    
    try {
      // Use set with merge instead of update to handle cases where document doesn't exist
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set(data, SetOptions(merge: true));
      print('User data updated successfully');
      return null; // Success
    } catch (e) {
      print('Error updating user data: $e');
      return 'Error updating user data: $e';
    }
  }

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
