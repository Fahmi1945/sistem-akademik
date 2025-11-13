// ========================================
// FILE: providers/auth_provider.dart
// ========================================

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String get userRole => _currentUser?.role ?? '';

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await DatabaseHelper.instance.login(username, password);

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    await DatabaseHelper.instance.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}
