import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth state listener
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;

      if (user != null) {
        try {
          _user = await _authService.getUserData(user.uid);
        } catch (e) {
          // Silently handle errors during user data fetch
          // This prevents crashes from Firestore read errors
          _errorMessage =
              null; // Don't show error to user for background operations
          debugPrint('Error fetching user data: $e');
        }
      } else {
        _user = null;
      }

      notifyListeners();
    }, onError: (error) {
      // Catch any auth state change errors (including PigeonUserDetails)
      debugPrint('Auth state change error (ignored): $error');
      // Don't propagate the error - just log it
    });
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    List<String>? expertise,
    List<String>? interests,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        expertise: expertise,
        interests: interests,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Check if it's the PigeonUserDetails error - ignore it
      String errorMsg = e.toString();
      if (errorMsg.contains('PigeonUserDetails') ||
          errorMsg.contains('List<Object?>')) {
        // This is the known Firebase Auth bug - user was created successfully
        debugPrint('PigeonUserDetails error (ignored): $e');
        _isLoading = false;
        _errorMessage = null; // Don't show error
        notifyListeners();
        return true; // Return success despite the error
      }

      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Check if it's the PigeonUserDetails error - ignore it
      String errorMsg = e.toString();
      if (errorMsg.contains('PigeonUserDetails') ||
          errorMsg.contains('List<Object?>')) {
        // This is the known Firebase Auth bug - login was successful
        debugPrint('PigeonUserDetails error (ignored): $e');
        _isLoading = false;
        _errorMessage = null; // Don't show error
        notifyListeners();
        return true; // Return success despite the error
      }

      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      if (isVerified && _user != null) {
        await _authService.updateUserData(_user!.uid, {'emailVerified': true});
        _user = _user!.copyWith(emailVerified: true);
        notifyListeners();
      }
      return isVerified;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user data
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_user == null) return false;

      await _authService.updateUserData(_user!.uid, data);
      _user = await _authService.getUserData(_user!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      try {
        _user = await _authService.getUserData(_firebaseUser!.uid);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }
}
