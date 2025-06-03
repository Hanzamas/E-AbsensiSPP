import 'package:flutter/material.dart';
import '../data/repositories/student_dashboard_repository.dart';
import '../data/models/user_profile_model.dart';
import '../data/models/schedule_model.dart';

class StudentDashboardProvider with ChangeNotifier {
  final StudentDashboardRepository _repository = StudentDashboardRepository();
  // Tambahkan property selectedSubject
  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;
  // Loading states
  bool _isLoading = false;
  
  // Data states
  UserProfileModel? _userProfile;
  List<Schedule> _todaySchedule = [];
  List<Schedule> _allSchedules = [];
  Map<String, int> _attendanceStats = {};
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  UserProfileModel? get userProfile => _userProfile;
  List<Schedule> get todaySchedule => _todaySchedule;
  List<Schedule> get allSchedules => _allSchedules;
  Map<String, int> get attendanceStats => _attendanceStats;
  String? get error => _error;

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getUserProfile(),
        _repository.getTodaySchedule(),
        _repository.getAllSchedules(),
        _repository.getAttendanceStats(),
      ]);

      _userProfile = results[0] as UserProfileModel;
      _todaySchedule = results[1] as List<Schedule>;
      _allSchedules = results[2] as List<Schedule>;
      _attendanceStats = results[3] as Map<String, int>;
      
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Student Dashboard Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
    // Tambahkan method untuk mendapatkan daftar mata pelajaran
  List<String> getAvailableSubjects() {
    final List<String> subjects = [];
    
    // Ambil mata pelajaran dari jadwal
    for (final schedule in _allSchedules) {
      if (!subjects.contains(schedule.mapel) && schedule.mapel.isNotEmpty) {
        subjects.add(schedule.mapel);
      }
    }
    
    // Tambahkan dari data kehadiran jika ada
    final subjectStats = _attendanceStats['perMapel'] as Map?;
    if (subjectStats != null) {
      for (final subject in subjectStats.keys) {
        if (!subjects.contains(subject) && subject.isNotEmpty) {
          subjects.add(subject.toString());
        }
      }
    }
    
    subjects.sort(); // Urutkan berdasarkan abjad
    return subjects;
  }
  // Method untuk memuat statistik kehadiran dengan filter mata pelajaran
  Future<void> loadAttendanceStatsBySubject(String? subject) async {
    _isLoading = true;
    _selectedSubject = subject;
    notifyListeners();

    try {
      final stats = await _repository.getAttendanceStatsBySubject(subject);
      _attendanceStats = stats;
    } catch (e) {
      debugPrint('Error loading attendance stats: $e');
      // Gunakan data cache jika ada error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}