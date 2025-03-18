import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl =
      'https://frontend-interview.touchinspiration.net/api/users';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    print('fetchUsers Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<User> fetchUser(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    print(
        'fetchUser($id) Status: ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }
}
