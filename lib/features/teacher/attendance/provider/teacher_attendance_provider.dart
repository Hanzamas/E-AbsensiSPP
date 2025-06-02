import 'package:flutter/material.dart';
import '../data/repository/teacher_attendance_repository.dart';
import '../data/model/teaching_schedule_model.dart';
import '../data/model/learning_session_model.dart';
import '../data/model/attendance_record_model.dart';

class TeacherAttendanceProvider with ChangeNotifier {
  final TeacherAttendanceRepository _repository = TeacherAttendanceRepository();

  // Loading states
  bool _isLoading = false;
  bool _isCreatingSession = false;
  bool _isUpdatingAttendance = false;
  bool _isLoadingStats = false;
  
  // Data states
  List<TeachingScheduleModel> _teachingSchedule = [];
  List<AttendanceRecordModel> _attendanceHistory = [];
  List<AttendanceRecordModel> _filteredAttendance = [];
  LearningSessionModel? _activeSession;
  Map<String, int> _attendanceStats = {};
  String? _error;
  
  // Filter states
  DateTime? _selectedDate;
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedStatus;

  // Tambahkan property baru
  List<String> _availableSubjects = [];
  List<String> _availableClasses = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters - Loading states
  bool get isLoading => _isLoading;
  bool get isCreatingSession => _isCreatingSession;
  bool get isUpdatingAttendance => _isUpdatingAttendance;
  bool get isLoadingStats => _isLoadingStats;
  // Tambahkan getters
  List<String> get availableSubjects => _availableSubjects;
  List<String> get availableClasses => _availableClasses;
  
  // Getters - Data states
  List<TeachingScheduleModel> get teachingSchedule => _teachingSchedule;
  List<AttendanceRecordModel> get attendanceHistory => _attendanceHistory;
  List<AttendanceRecordModel> get filteredAttendance => _filteredAttendance;
  LearningSessionModel? get activeSession => _activeSession;
  Map<String, int> get attendanceStats => _attendanceStats;
  String? get error => _error;
  
  // Getters - Filter states
  DateTime? get selectedDate => _selectedDate;
  String? get selectedSubject => _selectedSubject;
  String? get selectedClass => _selectedClass;
  String? get selectedStatus => _selectedStatus;

  // Computed properties
  List<TeachingScheduleModel> get todaySchedule => 
      _teachingSchedule.where((schedule) => schedule.isToday).toList();
  
  List<TeachingScheduleModel> get activeSchedule => 
      _teachingSchedule.where((schedule) => schedule.isActiveNow).toList();
  
  bool get hasActiveSession => _activeSession != null;
  bool get hasTodayClasses => todaySchedule.isNotEmpty;
  bool get hasActiveClasses => activeSchedule.isNotEmpty;
  
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

  // Load teaching schedule
  Future<void> loadTeachingSchedule() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teachingSchedule = await _repository.getTeachingSchedule();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading teaching schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance history
  Future<void> loadAttendanceHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceHistory = await _repository.getAttendanceHistory();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading attendance history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance stats
  Future<void> loadAttendanceStats([DateTime? date]) async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _attendanceStats = await _repository.getAttendanceStats(date);
    } catch (e) {
      debugPrint('Error loading attendance stats: $e');
      _attendanceStats = {};
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Create learning session
  Future<bool> createLearningSession(int idPengajaran) async {
    _isCreatingSession = true;
    _error = null;
    notifyListeners();

    try {
      _activeSession = await _repository.createLearningSession(idPengajaran);
      
      // Refresh attendance and stats after creating session
      await Future.wait([
        loadAttendanceHistory(),
        loadAttendanceStats(),
      ]);
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating learning session: $e');
      return false;
    } finally {
      _isCreatingSession = false;
      notifyListeners();
    }
  }

  // Update attendance status
  Future<bool> updateAttendanceStatus(int id, String status, String? keterangan) async {
    _isUpdatingAttendance = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateAttendanceStatus(id, status, keterangan);
      
      // Refresh attendance and stats after update
      await Future.wait([
        loadAttendanceHistory(),
        loadAttendanceStats(),
      ]);
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error updating attendance status: $e');
      return false;
    } finally {
      _isUpdatingAttendance = false;
      notifyListeners();
    }
  }
    // Load metadata untuk filter
  Future<void> loadFilterMetadata() async {
    try {
      final subjects = await _repository.getAvailableSubjects();
      final classes = await _repository.getAvailableClasses();
      
      _availableSubjects = subjects;
      _availableClasses = classes;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading filter metadata: $e');
    }
  }
    // Tambahkan fungsi untuk mendapatkan tren kehadiran
  Future<Map<String, List<double>>> getAttendanceTrend() async {
    try {
      final now = DateTime.now();
      final result = <String, List<double>>{
        'attendance': [],
        'dates': [],
      };
      
      // Get data for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final stats = await _repository.getAttendanceStats(date);
        
        final total = stats['total'] ?? 0;
        final present = stats['hadir'] ?? 0;
        
        double attendanceRate = 0;
        if (total > 0) {
          attendanceRate = (present / total) * 100;
        }
        
        result['attendance']!.add(attendanceRate);
        result['dates']!.add(date.day.toDouble());
      }
      
      return result;
    } catch (e) {
      debugPrint('Error getting attendance trend: $e');
      return {
        'attendance': [0, 0, 0, 0, 0, 0, 0],
        'dates': [1, 2, 3, 4, 5, 6, 7],
      };
    }
  }

  // Get attendance by ID
  Future<AttendanceRecordModel?> getAttendanceById(int id) async {
    try {
      return await _repository.getAttendanceById(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error getting attendance by ID: $e');
      return null;
    }
  }

  // Filter methods
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }
  // Tambahkan setter untuk date range filter
  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    notifyListeners();
  }

  void setSubjectFilter(String? subject) {
    _selectedSubject = subject;
    _applyFilters();
    notifyListeners();
  }

  void setClassFilter(String? className) {
    _selectedClass = className;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDate = null;
    _selectedSubject = null;
    _selectedClass = null;
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

// Perbaikan pada _applyFilters() untuk mendukung date range
void _applyFilters() {
  _filteredAttendance = _attendanceHistory.where((record) {
    bool matchDateRange = true;
    bool matchSubject = true;
    bool matchClass = true;
    bool matchStatus = true;

    // Single date filter
    if (_selectedDate != null) {
      matchDateRange = record.tanggal.year == _selectedDate!.year &&
                     record.tanggal.month == _selectedDate!.month &&
                     record.tanggal.day == _selectedDate!.day;
    }
    // Date range filter
    else if (_startDate != null && _endDate != null) {
      matchDateRange = record.tanggal.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                     record.tanggal.isBefore(_endDate!.add(const Duration(days: 1)));
    }

    // Subject filter
    if (_selectedSubject != null && _selectedSubject!.isNotEmpty) {
      matchSubject = record.namaMapel.toLowerCase() == _selectedSubject!.toLowerCase();
    }

    // Class filter
    if (_selectedClass != null && _selectedClass!.isNotEmpty) {
      matchClass = record.namaKelas.toLowerCase() == _selectedClass!.toLowerCase();
    }

    // Status filter
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      matchStatus = record.status.toLowerCase() == _selectedStatus!.toLowerCase();
    }

    return matchDateRange && matchSubject && matchClass && matchStatus;
  }).toList();
}
List<dynamic> getSchedulesByDay(String day) {
  return _teachingSchedule
      .where((schedule) => schedule.hari.toLowerCase() == day.toLowerCase())
      .toList();
}

bool isScheduleToday(dynamic schedule) {
  if (schedule == null) return false;
  
  final now = DateTime.now();
  final dayNames = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
  final today = dayNames[now.weekday % 7];
  
  return schedule.hari.toLowerCase() == today.toLowerCase();
}

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadTeachingSchedule(),
      loadAttendanceHistory(),
      loadAttendanceStats(),
      loadFilterMetadata(), // Tambahkan ini
    ]);
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadAllData();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get available filter options
  Future<List<String>> getAvailableSubjects() async {
    try {
      return await _repository.getAvailableSubjects();
    } catch (e) {
      debugPrint('Error getting available subjects: $e');
      return [];
    }
  }

  Future<List<String>> getAvailableClasses() async {
    try {
      return await _repository.getAvailableClasses();
    } catch (e) {
      debugPrint('Error getting available classes: $e');
      return [];
    }
  }

  // Helper methods
  bool get hasFiltersApplied => 
      _selectedDate != null || 
      (_selectedSubject != null && _selectedSubject!.isNotEmpty) ||
      (_selectedClass != null && _selectedClass!.isNotEmpty) ||
      (_selectedStatus != null && _selectedStatus!.isNotEmpty);

  int get totalFilteredRecords => _filteredAttendance.length;

  // Get attendance record by ID from filtered list
  AttendanceRecordModel? getFilteredAttendanceById(int id) {
    try {
      return _filteredAttendance.firstWhere((record) => record.idAbsensi == id);
    } catch (e) {
      return null;
    }
  }

  // Get today's active teaching schedule
  List<TeachingScheduleModel> get todayActiveSchedule {
    final now = DateTime.now();
    return todaySchedule.where((schedule) {
      try {
        final startHour = int.parse(schedule.jamMulai.split(':')[0]);
        final startMinute = int.parse(schedule.jamMulai.split(':')[1]);
        final endHour = int.parse(schedule.jamSelesai.split(':')[0]);
        final endMinute = int.parse(schedule.jamSelesai.split(':')[1]);
        
        final nowMinutes = now.hour * 60 + now.minute;
        final startMinutes = startHour * 60 + startMinute;
        final endMinutes = endHour * 60 + endMinute;
        
        return nowMinutes >= (startMinutes - 30) && nowMinutes <= endMinutes; // 30 minutes before start
      } catch (e) {
        return false;
      }
    }).toList();
  }
}