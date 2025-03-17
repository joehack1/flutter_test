import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _apiService.fetchUsers();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedUser = await _apiService.fetchUser(id);
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedUser = await _apiService.updateUser(user.id, user);
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _selectedUser = updatedUser;
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }
}