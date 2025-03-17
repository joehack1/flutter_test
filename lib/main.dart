import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// User Model
class User {
  final int id;
  final String name;
  final String email;
  final String occupation;
  final String bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.occupation,
    required this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      occupation: json['occupation'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'occupation': occupation,
    'bio': bio,
  };
}

// ApiService
class ApiService {
  static const String baseUrl =
      'https://frontend-interview.touchinspiration.net/api/users';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<User> fetchUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  Future<User> updateUser(int id, User user) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
}

// UserProvider
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
    _updateState(isLoading: true, error: null);
    try {
      final updatedUser = await _apiService.updateUser(user.id, user);
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

// Main App
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
        cardTheme: const CardTheme(elevation: 2),
      ),
      home: const UserListScreen(),
    );
  }
}

// User List Screen
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Users')),
          body: _buildBody(userProvider),
          floatingActionButton: FloatingActionButton(
            onPressed:
                userProvider.isLoading ? null : () => userProvider.fetchUsers(),
            tooltip: 'Refresh',
            child:
                userProvider.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildBody(UserProvider userProvider) {
    if (userProvider.isLoading && userProvider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userProvider.error != null) {
      return Center(child: Text('Error: ${userProvider.error}'));
    }
    if (userProvider.users.isEmpty) {
      return const Center(
        child: Text('No users found. Tap refresh to try again.'),
      );
    }
    return RefreshIndicator(
      onRefresh: userProvider.fetchUsers,
      child: ListView.separated(
        itemCount: userProvider.users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.occupation),
              trailing: const Icon(Icons.edit, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEditScreen(userId: user.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// User Edit Screen
class UserEditScreen extends StatefulWidget {
  final int userId;
  const UserEditScreen({super.key, required this.userId});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _occupationController;
  late TextEditingController _bioController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
    _bioController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUser(widget.userId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!_isInit && userProvider.selectedUser != null) {
          final user = userProvider.selectedUser!;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _occupationController.text = user.occupation;
          _bioController.text = user.bio;
          _isInit = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit User')),
          body:
              userProvider.isLoading && userProvider.selectedUser == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _occupationController,
                            decoration: const InputDecoration(
                              labelText: 'Occupation',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                userProvider.isLoading
                                    ? null
                                    : () {
                                      if (_formKey.currentState!.validate()) {
                                        final updatedUser = User(
                                          id: widget.userId,
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          occupation:
                                              _occupationController.text,
                                          bio: _bioController.text,
                                        );
                                        userProvider.updateUser(updatedUser).then(
                                          (_) {
                                            if (userProvider.error == null) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'User updated successfully',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    userProvider.error!,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                            child:
                                userProvider.isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
