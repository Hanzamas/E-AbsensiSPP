import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class UserInfoService {
  static const String userInfoKey = 'student_user_info';
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(userInfoKey);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    } else {
      // Tidak ada cache, fetch dari API
      try {
        final response = await _dio.get(ApiEndpoints.usersMy);
        if (response.statusCode == 200 && response.data['data'] != null) {
          final data = response.data['data'] as Map<String, dynamic>;
          await prefs.setString(userInfoKey, json.encode(data));
          return data;
        }
      } catch (e) {
        // ignore error, return null
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> refreshUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get(ApiEndpoints.usersMy);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        await prefs.setString(userInfoKey, json.encode(data));
        return data;
      }
    } catch (e) {
      // ignore error, return null
    }
    return null;
  }

  Future<void> clearUserInfoCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userInfoKey);
  }
} 