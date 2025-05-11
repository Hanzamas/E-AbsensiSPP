import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = ApiEndpoints.baseUrl;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Registration failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.forgotPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to send reset link';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.verifyOtp}/$otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> resetPassword(String otp, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.resetPassword}/$otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Password reset failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.logout}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'] ?? 'Logout failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.userData}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to get user data';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
