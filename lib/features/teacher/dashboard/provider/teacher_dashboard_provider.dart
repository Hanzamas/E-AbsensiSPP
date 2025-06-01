import 'package:flutter/material.dart';
import '../data/repository/teacher_dashboard_repository.dart';
import '../data/model/user_profile_model.dart';
import '../data/model/schedule_model.dart';

class TeacherDashboardProvider with ChangeNotifier {
  final TeacherDashboardRepository _repository = TeacherDashboardRepository();

  // Loading states
  bool _isLoading = false;
  bool _isStartingSession = false;
  
  // Data states
  UserProfileModel? _userProfile;
  List<ScheduleModel> _todaySchedule = [];
  Map<String, int> _attendanceStats = {};
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isStartingSession => _isStartingSession;
  UserProfileModel? get userProfile => _userProfile;
  List<ScheduleModel> get todaySchedule => _todaySchedule;
  Map<String, int> get attendanceStats => _attendanceStats;
  String? get error => _error;

  // Computed properties
  String get teacherName => _userProfile?.displayName ?? 'Guru';
  String get greetingName => _userProfile?.greetingName ?? 'Pak/Bu Guru';
  String get teacherRole => _userProfile?.role ?? 'teacher';
  bool get hasClassToday => _todaySchedule.isNotEmpty;

  // Stats getters
  int get totalStudents => _attendanceStats['total'] ?? 0;
  int get presentToday => _attendanceStats['hadir'] ?? 0;
  int get absentToday => _attendanceStats['alpha'] ?? 0;
  int get sickToday => _attendanceStats['sakit'] ?? 0;
  int get permissionToday => _attendanceStats['izin'] ?? 0;

  double get attendanceRate {
    if (totalStudents == 0) return 0.0;
    return (presentToday / totalStudents) * 100;
  }

  String get attendanceRateText => '${attendanceRate.toStringAsFixed(1)}%';

  String get currentTimeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getUserProfile(),
        _repository.getTodaySchedule(),
        _repository.getAttendanceStats(),
      ]);

      _userProfile = results[0] as UserProfileModel;
      _todaySchedule = results[1] as List<ScheduleModel>;
      _attendanceStats = results[2] as Map<String, int>;
      
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Dashboard Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start learning session
  Future<bool> startLearningSession(int idPengajaran) async {
    _isStartingSession = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.startSession(idPengajaran);
      
      // Refresh stats after starting session
      _attendanceStats = await _repository.getAttendanceStats();
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Start Session Error: $e');
      return false;
    } finally {
      _isStartingSession = false;
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
}