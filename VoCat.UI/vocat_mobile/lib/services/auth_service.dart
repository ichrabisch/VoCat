import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String userIdKey = 'userId';

  Future<bool> login(
    String email,
    String password,
    String preferredLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/User/login'),
        headers: ApiConfig.headers,
        body: jsonEncode(
          User(
            email: email,
            passwordHash: password,
            preferredLanguage: preferredLanguage,
            userName: 'test',
          ).toJson(),
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userId = responseData['userId'];
        if (userId != null) {
          await _saveUserId(userId);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }
}
