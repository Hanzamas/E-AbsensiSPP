import 'package:flutter/material.dart';
import '../services/student_dashboard_service.dart';
import '../models/schedule_model.dart';
import '../models/user_profile_model.dart';

class StudentDashboardRepository {
  static final StudentDashboardRepository _instance = StudentDashboardRepository._internal();
  late final StudentDashboardService _service;
  
  // Private constructor
  StudentDashboardRepository._internal() {
    _service = StudentDashboardService();
  }

  // Singleton factory
  factory StudentDashboardRepository() => _instance;

  /// Get user profile from API (Independent)
  Future<UserProfileModel> getUserProfile() async {
    try {
      final data = await _service.getUserProfile();
      return UserProfileModel.fromJson(data);
    } catch (e) {
      debugPrint('📊 Repository getUserProfile error: $e');
      throw Exception('Repository Error - getUserProfile: $e');
    }
  }

  /// Get today's schedule
  Future<List<Schedule>> getTodaySchedule() async {
    try {
      final data = await _service.getStudentSchedule();
      final schedules = data.map((json) => Schedule.fromJson(json)).toList();
      
      // Filter untuk hari ini
      final now = DateTime.now();
      final daysOfWeek = ['senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'];
      final today = now.weekday <= 7 ? daysOfWeek[now.weekday - 1] : daysOfWeek[0];
      
      return schedules.where((schedule) => 
        schedule.hari.toLowerCase() == today.toLowerCase()
      ).toList();
    } catch (e) {
      debugPrint('📊 Repository getTodaySchedule error: $e');
      throw Exception('Repository Error - getTodaySchedule: $e');
    }
  }

  /// Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final data = await _service.getStudentSchedule();
      return data.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      debugPrint('📊 Repository getAllSchedules error: $e');
      throw Exception('Repository Error - getAllSchedules: $e');
    }
  }

  /// Get attendance statistics
  Future<Map<String, int>> getAttendanceStats() async {
    try {
      return await _service.getAttendanceStats();
    } catch (e) {
      debugPrint('📊 Repository getAttendanceStats error: $e');
      
      // ✅ Return zero stats instead of throwing error
      return {
        'total': 0,
        'hadir': 0,
        'alpha': 0,
        'sakit': 0,
        'izin': 0,
      };
    }
  }
}