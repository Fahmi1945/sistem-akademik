// ========================================
// FILE: providers/user_provider.dart
// ========================================

import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  List<User> _userList = [];
  List<User> _filteredUserList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<User> get userList => _filteredUserList;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userList = await DatabaseHelper.instance.getAllUsers();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    try {
      await DatabaseHelper.instance.createUser(user);
      await loadUsers();
    } catch (e) {
      debugPrint('Error adding user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await DatabaseHelper.instance.updateUser(user);
      await loadUsers();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await DatabaseHelper.instance.deleteUser(id);
      await loadUsers();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUserList = List.from(_userList);
    } else {
      _filteredUserList = _userList.where((user) {
        return user.username.toLowerCase().contains(_searchQuery) ||
            user.nama.toLowerCase().contains(_searchQuery) ||
            user.role.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  List<User> getUsersByRole(String role) {
    return _userList.where((user) => user.role == role).toList();
  }
}