import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _name;

  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;

  void setUser(String id, String email, String name) {
    _userId = id;
    _email = email;
    _name = name;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _email = null;
    _name = null;
    notifyListeners();
  }
}
