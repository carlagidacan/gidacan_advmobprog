import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constrants.dart';

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$host/api/users/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String age,
    required String gender,
    required String contactNumber,
    required String email,
    required String username,
    required String password,
    required String address,
    String type = 'editor',
  }) async {
    final response = await http.post(
      Uri.parse('$host/api/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'gender': gender,
        'contactNumber': contactNumber,
        'email': email,
        'username': username,
        'password': password,
        'address': address,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Registration failed: ${response.statusCode} ${response.body}');
    }
  }


  // Save data into SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', userData['firstName'] ?? '');
    await prefs.setString('lastName', userData['lastName'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('contactNumber', userData['contactNumber'] ?? '');
    await prefs.setString('address', userData['address'] ?? '');
    await prefs.setString('gender', userData['gender'] ?? '');
    await prefs.setString('age', userData['age'] ?? '');
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString('type', userData['type'] ?? '');
  }

  //Retrieve User Data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'email': prefs.getString('email') ?? '',
      'contactNumber': prefs.getString('contactNumber') ?? '',
      'address': prefs.getString('address') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'age': prefs.getString('age') ?? '',
      'token': prefs.getString('token') ?? '',
      'type': prefs.getString('type') ?? '',
    };
  }

  Future<Map<String, dynamic>?> fetchUserByEmail(String email) async {
    try {
      final users = await fetchUsers();
      final match = users.firstWhere(
        (u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase(),
        orElse: () => null,
      );
      if (match == null) return null;
      if (match is Map<String, dynamic>) return match;
      return Map<String, dynamic>.from(match as Map);
    } catch (_) {
      return null;
    }
  }

  // Check if User is Logged In
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Logout and Clear User Data
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$host/api/users'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['users'] is List) {
        return decoded['users'] as List<dynamic>;
      }
      return [];
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      final users = await fetchUsers();
      return users.any((u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase());
    } catch (_) {
      return false; // fail open to not block user if check fails
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final users = await fetchUsers();
      return users.any((u) => (u['username'] ?? '').toString().toLowerCase() == username.toLowerCase());
    } catch (_) {
      return false;
    }
  }
}