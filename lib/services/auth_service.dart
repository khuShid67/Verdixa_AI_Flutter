import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'usage_service.dart';

class AuthService {
  static const String baseUrl = "http://YOUR_IP:3000";

  static const String _loginKey = "is_logged_in";
  static const String _userKey = "current_user";

  static Future<bool> register(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": user.email,
          "password": user.password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_loginKey, true);
          await prefs.setString(_userKey, email);

          // ✅ RESET SCANS AFTER LOGIN
          await UsageService.resetUsage();

          return true;
        }
      }

      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_userKey);
  }
}