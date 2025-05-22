import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_absensi/features/student/dashboard/data/models/schedule_model.dart';
import 'package:e_absensi/features/student/dashboard/data/services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  static final ScheduleProvider _instance = ScheduleProvider._internal();
  late final ScheduleService _scheduleService;
  List<Schedule>? _schedules;
  bool _isLoading = false;

  // Private constructor
  ScheduleProvider._internal() {
    _scheduleService = ScheduleService();
  }

  // Singleton factory
  factory ScheduleProvider() => _instance;

  List<Schedule>? get schedules => _schedules;
  bool get isLoading => _isLoading;

  // Method untuk inisialisasi awal setelah login
  Future<void> initializeSchedules() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Ambil dari API saat pertama kali login
      final schedules = await _scheduleService.getStudentSchedule();
      _schedules = schedules;
      
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'student_schedules',
        json.encode(schedules.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      print('Error initialize schedules: $e');
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Method untuk load data dari SharedPreferences
  Future<void> loadSchedules() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Ambil dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('student_schedules');
      if (schedulesJson != null) {
        final List<dynamic> decoded = json.decode(schedulesJson);
        _schedules = decoded.map((item) => Schedule.fromJson(item)).toList();
      } else {
        // Tidak ada cache, fetch dari API
        final schedules = await _scheduleService.getStudentSchedule();
        _schedules = schedules;
        await prefs.setString(
          'student_schedules',
          json.encode(schedules.map((s) => s.toJson()).toList()),
        );
      }
    } catch (e) {
      print('Error load schedules: $e');
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> refreshSchedules() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Ambil data terbaru dari API
      final schedules = await _scheduleService.getStudentSchedule();
      
      // Simpan data terbaru ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'student_schedules',
        json.encode(schedules.map((s) => s.toJson()).toList()),
      );
      
      // Update state dengan data baru
      _schedules = schedules;
    } catch (e) {
      print('Error refresh schedules: $e');
      // Jika error, biarkan data lama tetap ada
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> clearSchedules() async {
    _schedules = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_schedules');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
} 