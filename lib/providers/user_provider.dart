import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  /// Fetches all users and updates the state.
  Future<void> fetchUsers() async {
    _updateState(isLoading: true, error: null);
    try {
      _users = await _apiService.fetchUsers();
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  /// Fetches a single user by ID and sets it as the selected user.
  Future<void> fetchUser(int id) async {
    _updateState(isLoading: true, error: null);
    try {
      _selectedUser = await _apiService.fetchUser(id);
      _updateState(isLoading: false);
    } catch (e) {
      _selectedUser = null; // Reset on failure
      _updateState(isLoading: false, error: e.toString());
    }
  }

  /// Updates a user and refreshes both the list and selected user.
  Future<void> updateUser(User user) async {
    if (user.id <= 0) throw ArgumentError('Invalid user ID');
    _updateState(isLoading: true, error: null);
    try {
      final updatedUser = await _apiService.updateUser(user.id, user);
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser; // Update local list
      } else {
        _users.add(updatedUser); // Add if not already in list
      }
      _selectedUser = updatedUser; // Update selected user
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  /// Centralized state update method to reduce boilerplate and ensure consistency.
  void _updateState({bool? isLoading, String? error}) {
    _isLoading = isLoading ?? _isLoading;
    _error = error ?? _error;
    notifyListeners();
  }

  /// Clears all state (e.g., for logout or reset).
  void reset() {
    _users = [];
    _selectedUser = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
