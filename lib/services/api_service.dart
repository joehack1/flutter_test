import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:developer' as dev;

class ApiService {
  static const String baseUrl =
      'https://frontend-interview.touchinspiration.net/api/users';

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      dev.log(
        'fetchUsers: ${response.statusCode} - ${response.body}',
        name: 'ApiService',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<User> fetchUser(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      dev.log(
        'fetchUser: ${response.statusCode} - ${response.body}',
        name: 'ApiService',
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<User> updateUser(int id, User user) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      dev.log(
        'updateUser: ${response.statusCode} - ${response.body}',
        name: 'ApiService',
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }
}
