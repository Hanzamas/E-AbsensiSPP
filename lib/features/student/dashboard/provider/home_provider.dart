
import 'package:flutter/material.dart';

import 'package:e_absensi/features/student/dashboard/data/models/schedule_model.dart';
import 'package:e_absensi/features/student/dashboard/data/models/user_model.dart';
import 'package:e_absensi/features/student/dashboard/data/repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  static final HomeProvider _instance = HomeProvider._internal();
  late final HomeRepository _repository;
  
  List<Schedule>? _schedules;
  User? _userInfo;
  bool _isLoading = false;
  String? _error;

  // Private constructor
  HomeProvider._internal() {
    _repository = HomeRepository();
    // Load data saat provider dibuat
    _initializeData();
  }

  // Singleton factory
  factory HomeProvider() => _instance;

  // Getters
  List<Schedule>? get schedules => _schedules;
  User? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Inisialisasi data
  Future<void> _initializeData() async {
    await loadUserInfo();
    await loadSchedules();
  }

  // Load user info dari SharedPreferences
  Future<void> loadUserInfo() async {
    try {
      final user = await _repository.getUserInfo();
      _userInfo = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  // Load jadwal dari cache atau API
  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Coba load dari cache dulu
      final cachedSchedules = await _repository.loadSchedulesFromCache();
      if (cachedSchedules != null) {
        _schedules = cachedSchedules;
        notifyListeners();
      }
      
      // Tetap refresh data di background
      await refreshSchedules(silent: cachedSchedules != null);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh jadwal dari API
  Future<void> refreshSchedules({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    
    try {
      final schedules = await _repository.getSchedules();
      _schedules = schedules;
      
      // Simpan ke cache
      await _repository.saveSchedulesToCache(schedules);
    } catch (e) {
      if (!silent) {
        _error = e.toString();
      }
      debugPrint('Error refreshing schedules: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      } else if (_schedules != null) {
        // Tetap notifyListeners jika data baru tersedia
        notifyListeners();
      }
    }
  }

  // Filter berdasarkan hari
  List<Schedule> getSchedulesByDay(String day) {
    if (_schedules == null) return [];
    
    return _schedules!.where(
      (schedule) => schedule.hari.toLowerCase() == day.toLowerCase()
    ).toList();
  }
  
  // Jadwal hari ini
  List<Schedule> get todaySchedules {
    final now = DateTime.now();
    final daysOfWeek = ['senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'];
    final today = now.weekday <= 7 ? daysOfWeek[now.weekday - 1] : daysOfWeek[0];
    
    return getSchedulesByDay(today);
  }

  // Clear data saat logout
  Future<void> clearData() async {
    _schedules = null;
    _userInfo = null;
    _error = null;
    await _repository.clearCache();
    notifyListeners();
  }
}