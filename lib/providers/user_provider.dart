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

  Future<void> fetchUsers() async {
    _updateState(isLoading: true, error: null);
    try {
      _users = await _apiService.fetchUsers();
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchUser(int id) async {
    _updateState(isLoading: true, error: null);
    try {
      _selectedUser = await _apiService.fetchUser(id);
      _updateState(isLoading: false);
    } catch (e) {
      _selectedUser = null;
      _updateState(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUser(User user) async {
    if (user.id == null) throw Exception('User ID cannot be null for update');
    _updateState(isLoading: true, error: null);
    try {
      final updatedUser = await _apiService.updateUser(user.id!, user);
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
      } else {
        _users.add(updatedUser);
      }
      _selectedUser = updatedUser;
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
    }
  }

  void _updateState({bool? isLoading, String? error}) {
    _isLoading = isLoading ?? _isLoading;
    _error = error ?? _error;
    notifyListeners();
  }
}
