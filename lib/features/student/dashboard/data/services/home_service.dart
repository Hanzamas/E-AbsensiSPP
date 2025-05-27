import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:e_absensi/features/student/dashboard/data/models/schedule_model.dart';
import 'package:e_absensi/features/student/dashboard/data/models/user_model.dart';

class HomeService {
  static final HomeService _instance = HomeService._internal();
  late final Dio _dio;
  
  // Caching untuk performa
  DateTime? _lastScheduleFetch;
  List<Schedule>? _cachedSchedules;
  User? _cachedUser;
  final Duration _cacheTimeout = const Duration(minutes: 5);

  // Private constructor
  HomeService._internal() {
    _dio = DioClient().dio;
  }

  // Singleton factory
  factory HomeService() => _instance;

  // Get user info dari SharedPreferences (Independen)
  Future<User> getDashboardUser() async {
    if (_cachedUser != null) return _cachedUser!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_info');
      
      if (userJson != null) {
        final userData = json.decode(userJson);
        _cachedUser = User.fromJson(userData);
        return _cachedUser!;
      }
      
      // Fallback jika tidak ada di SharedPreferences
      return User.empty();
    } catch (e) {
      debugPrint('Error getting dashboard user: $e');
      return User.empty();
    }
  }

  Future<List<Schedule>> getStudentSchedule() async {
    // Gunakan cache jika valid dan ada
    if (_cachedSchedules != null && 
        _lastScheduleFetch != null && 
        DateTime.now().difference(_lastScheduleFetch!) < _cacheTimeout) {
      return _cachedSchedules!;
    }
    
    try {
      final response = await _dio.get(ApiEndpoints.getStudentSchedule);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final schedules = data.map((json) => Schedule.fromJson(json)).toList();
        
        // Update cache
        _cachedSchedules = schedules;
        _lastScheduleFetch = DateTime.now();
        
        return schedules;
      }
      throw 'Gagal mengambil jadwal: ${response.statusCode}';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'Sesi anda telah berakhir. Silakan login kembali.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout) {
        throw 'Koneksi timeout. Periksa koneksi internet Anda.';
      }
      throw 'Gagal mengambil jadwal: ${e.message}';
    } catch (e) {
      throw 'Gagal mengambil jadwal: $e';
    }
  }

  // Clear cache ketika logout
  void clearCache() {
    _cachedSchedules = null;
    _lastScheduleFetch = null;
    _cachedUser = null;
  }
}