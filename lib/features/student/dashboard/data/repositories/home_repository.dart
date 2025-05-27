import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/home_service.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';

class HomeRepository {
  static final HomeRepository _instance = HomeRepository._internal();
  late final HomeService _service;
  
  // Private constructor
  HomeRepository._internal() {
    _service = HomeService();
  }

  // Singleton factory
  factory HomeRepository() => _instance;

  // Mendapatkan user info dari SharedPreferences
  Future<User> getUserInfo() async {
    try {
      return await _service.getDashboardUser();
    } catch (e) {
      debugPrint('Error in HomeRepository.getUserInfo: $e');
      rethrow;
    }
  }

  // Mendapatkan jadwal
  Future<List<Schedule>> getSchedules() async {
    try {
      return await _service.getStudentSchedule();
    } catch (e) {
      debugPrint('Error in HomeRepository.getSchedules: $e');
      rethrow;
    }
  }

  // Simpan jadwal ke SharedPreferences
  Future<void> saveSchedulesToCache(List<Schedule> schedules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'student_schedules',
        json.encode(schedules.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving schedules to cache: $e');
    }
  }

  // Muat jadwal dari SharedPreferences
  Future<List<Schedule>?> loadSchedulesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('student_schedules');
      
      if (schedulesJson != null) {
        final List<dynamic> decoded = json.decode(schedulesJson);
        return decoded.map((item) => Schedule.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error loading schedules from cache: $e');
      return null;
    }
  }

  // Clear cache ketika logout
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('student_schedules');
      _service.clearCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}