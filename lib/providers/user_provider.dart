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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _apiService.fetchUsers();
      print('Fetched ${_users.length} users');
    } catch (e) {
      print('Error fetching users: $e');
      _users = _mockUsers();
      _error = 'Failed to fetch users, using mock data';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedUser = await _apiService.fetchUser(id);
      print('Fetched user: ${_selectedUser?.name}');
    } catch (e) {
      print('Error fetching user: $e');
      _selectedUser = _users.firstWhere(
        (u) => u.id == id,
        orElse: () => User(
          id: id,
          name: 'Unknown',
          email: 'No email',
          occupation: 'No occupation',
          bio: 'User data unavailable',
        ),
      );
      _error = 'Failed to fetch user with ID $id from API, using cached data';
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedUser(User user) {
    _selectedUser = user;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    if (user.id == null) {
      _error = 'Cannot edit user: ID is missing';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    // Update locally only, no API call since PATCH /api/users/{id} returns 404
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      _selectedUser = user;
      print('Updated user locally: ${user.name}');
    } else {
      _error = 'User not found in list to update';
    }
    _isLoading = false;
    notifyListeners();
  }

  List<User> _mockUsers() {
    return [
      User(
          id: "1",
          name: "Barret",
          email: "bwallbutton0@salon.com",
          occupation: "Engineer",
          bio: "Lorem ipsum"),
      User(
          id: "2",
          name: "Alice",
          email: "alice@example.com",
          occupation: "Designer",
          bio: "Dolor sit amet"),
    ];
  }
}
