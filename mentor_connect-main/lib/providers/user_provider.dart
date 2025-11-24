import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  List<UserModel> _mentors = [];
  List<UserModel> _filteredMentors = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get mentors =>
      _filteredMentors.isEmpty ? _mentors : _filteredMentors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load current user
  Future<void> loadUser(String uid) async {
    try {
      _currentUser = await _firestoreService.getUser(uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear current user
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Load all mentors
  Future<void> loadMentors() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _mentors = await _firestoreService.getAllMentors();
      _filteredMentors = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search mentors
  Future<void> searchMentors(String query) async {
    try {
      if (query.isEmpty) {
        _filteredMentors = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      _filteredMentors = await _firestoreService.searchMentors(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    _filteredMentors = [];
    notifyListeners();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      return await _firestoreService.getUser(uid);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateUser(uid, data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
