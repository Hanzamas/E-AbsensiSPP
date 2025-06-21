import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ ADD
import 'dart:convert'; // ✅ ADD
import '../data/repository/teacher_attendance_repository.dart';
import '../data/model/teaching_schedule_model.dart';
import '../data/model/learning_session_model.dart';
import '../data/model/attendance_record_model.dart';

class TeacherAttendanceProvider with ChangeNotifier {
  final TeacherAttendanceRepository _repository = TeacherAttendanceRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // ✅ ADD

  // Loading states
  bool _isLoading = false;
  bool _isCreatingSession = false;
  bool _isUpdatingAttendance = false;
  bool _isLoadingStats = false;
  
  // ✅ ENHANCED: Session management with persistence
  final Set<int> _activeSessionIds = <int>{};
  final Set<int> _completedSessionIds = <int>{};
  final Map<int, LearningSessionModel> _sessionData = {}; // ✅ Store session data
  DateTime? _lastSessionCheck;
  
  // Data states (existing...)
  List<TeachingScheduleModel> _teachingSchedule = [];
  List<AttendanceRecordModel> _attendanceHistory = [];
  List<AttendanceRecordModel> _filteredAttendance = [];
  Map<String, int> _attendanceStats = {};
  String? _error;
  
  // Filter states (existing...)
  DateTime? _selectedDate;
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedStatus;
  List<String> _availableSubjects = [];
  List<String> _availableClasses = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters - Loading states
  bool get isLoading => _isLoading;
  bool get isCreatingSession => _isCreatingSession;
  bool get isUpdatingAttendance => _isUpdatingAttendance;
  bool get isLoadingStats => _isLoadingStats;
  List<String> get availableSubjects => _availableSubjects;
  List<String> get availableClasses => _availableClasses;
  
  // Getters - Data states
  List<TeachingScheduleModel> get teachingSchedule => _teachingSchedule;
  List<AttendanceRecordModel> get attendanceHistory => _attendanceHistory;
  List<AttendanceRecordModel> get filteredAttendance => _filteredAttendance;
  Map<String, int> get attendanceStats => _attendanceStats;
  String? get error => _error;
  
  // Getters - Filter states
  DateTime? get selectedDate => _selectedDate;
  String? get selectedSubject => _selectedSubject;
  String? get selectedClass => _selectedClass;
  String? get selectedStatus => _selectedStatus;

  // ✅ ENHANCED: Session state getters
  Set<int> get activeSessionIds => Set.unmodifiable(_activeSessionIds);
  Set<int> get completedSessionIds => Set.unmodifiable(_completedSessionIds);
  
  bool isSessionActive(int scheduleId) => _activeSessionIds.contains(scheduleId);
  bool isSessionCompleted(int scheduleId) => _completedSessionIds.contains(scheduleId);

  // ✅ FIXED: hasActiveSession with time validation
  bool get hasActiveSession {
    if (_activeSessionIds.isEmpty) return false;
    
    final now = DateTime.now();
    for (final sessionId in _activeSessionIds) {
      final sessionData = _sessionData[sessionId];
      if (sessionData != null) {
        try {
          final endTimeParts = sessionData.jamSelesai.split(':');
          final endTime = DateTime(
            now.year, now.month, now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );
          
          if (now.isBefore(endTime)) {
            return true;
          }
        } catch (e) {
          debugPrint('Error checking session time: $e');
        }
      }
    }
    return false;
  }

  // ✅ FIXED: activeSession getter with stored data
  LearningSessionModel? get activeSession {
    if (!hasActiveSession || _activeSessionIds.isEmpty) return null;
    
    final now = DateTime.now();
    for (final sessionId in _activeSessionIds) {
      final sessionData = _sessionData[sessionId];
      if (sessionData != null) {
        try {
          final endTimeParts = sessionData.jamSelesai.split(':');
          final endTime = DateTime(
            now.year, now.month, now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );
          
          if (now.isBefore(endTime)) {
            return sessionData;
          }
        } catch (e) {
          debugPrint('Error getting active session: $e');
        }
      }
    }
    return null;
  }

  // Computed properties
  List<TeachingScheduleModel> get todaySchedule {
    final today = _getCurrentDay();
    return _teachingSchedule.where((schedule) {
      final scheduleDay = _normalizeDay(schedule.hari);
      final currentDay = _normalizeDay(today);
      return scheduleDay == currentDay;
    }).toList();
  }
  
  List<TeachingScheduleModel> get activeSchedule => 
      _teachingSchedule.where((schedule) => schedule.isActiveNow).toList();
  
  bool get hasTodayClasses => todaySchedule.isNotEmpty;
  bool get hasActiveClasses => activeSchedule.isNotEmpty;
  
  // Stats getters (existing...)
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

  // ✅ ADD: Session persistence methods
  Future<void> _saveSessionData() async {
    try {
      final sessionJson = {
        'activeSessionIds': _activeSessionIds.toList(),
        'completedSessionIds': _completedSessionIds.toList(),
        'sessionData': _sessionData.map((key, value) => MapEntry(
          key.toString(),
          {
            'idSesi': value.idSesi,
            'idPengajaran': value.idPengajaran,
            'date': value.date,
            'qrToken': value.qrToken,
            'jamMulai': value.jamMulai,
            'jamSelesai': value.jamSelesai,
          }
        )),
        'lastSessionCheck': _lastSessionCheck?.millisecondsSinceEpoch,
      };
      
      await _storage.write(
        key: 'teacher_session_data',
        value: jsonEncode(sessionJson),
      );
    } catch (e) {
      debugPrint('Error saving session data: $e');
    }
  }

  Future<void> _loadSessionData() async {
    try {
      final sessionDataString = await _storage.read(key: 'teacher_session_data');
      if (sessionDataString != null) {
        final sessionJson = jsonDecode(sessionDataString);
        
        _activeSessionIds.clear();
        _activeSessionIds.addAll(
          (sessionJson['activeSessionIds'] as List).cast<int>()
        );
        
        _completedSessionIds.clear();
        _completedSessionIds.addAll(
          (sessionJson['completedSessionIds'] as List).cast<int>()
        );
        
        _sessionData.clear();
        final sessionDataMap = sessionJson['sessionData'] as Map<String, dynamic>;
        sessionDataMap.forEach((key, value) {
          _sessionData[int.parse(key)] = LearningSessionModel(
            idSesi: value['idSesi'],
            idPengajaran: value['idPengajaran'],
            date: value['date'],
            qrToken: value['qrToken'],
            jamMulai: value['jamMulai'],
            jamSelesai: value['jamSelesai'],
          );
        });
        
        if (sessionJson['lastSessionCheck'] != null) {
          _lastSessionCheck = DateTime.fromMillisecondsSinceEpoch(
            sessionJson['lastSessionCheck']
          );
        }
        
        // Check if sessions are still valid
        await checkSessionStatus();
      }
    } catch (e) {
      debugPrint('Error loading session data: $e');
    }
  }

  Future<void> _clearSessionData() async {
    try {
      await _storage.delete(key: 'teacher_session_data');
      _activeSessionIds.clear();
      _completedSessionIds.clear();
      _sessionData.clear();
      _lastSessionCheck = null;
    } catch (e) {
      debugPrint('Error clearing session data: $e');
    }
  }

  // ✅ ADD: Helper methods
  String _normalizeDay(String day) {
    final normalized = day
        .toLowerCase()
        .trim()
        .replaceAll("'", '')
        .replaceAll("'", '')
        .replaceAll(" ", '');
    
    const dayMap = {
      'senin': 'senin',
      'selasa': 'selasa', 
      'rabu': 'rabu',
      'kamis': 'kamis',
      'jumat': 'jumat',
      'jumaat': 'jumat',
      'sabtu': 'sabtu',
      'minggu': 'minggu',
    };
    
    return dayMap[normalized] ?? normalized;
  }

  String _getCurrentDay() {
    final today = DateTime.now().weekday;
    const days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];
    return days[today - 1];
  }

  // ✅ ENHANCED: Load teaching schedule with session data
  Future<void> loadTeachingSchedule() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teachingSchedule = await _repository.getTeachingSchedule();
      await _loadSessionData(); // ✅ Load persisted session data
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading teaching schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance history (existing...)
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

  // Load attendance stats (existing...)
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

  // ✅ FIXED: Create learning session with persistence
  Future<bool> createLearningSession(int idPengajaran) async {
    // ✅ Prevent multiple session creation
    if (isSessionActive(idPengajaran) || _isCreatingSession) {
      return false;
    }

    _isCreatingSession = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createLearningSession(idPengajaran);
      
      if (result != null) {
        // ✅ Add to active sessions and store data
        _activeSessionIds.add(idPengajaran);
        _sessionData[idPengajaran] = result;
        _lastSessionCheck = DateTime.now();
        
        // ✅ Save to storage for persistence
        await _saveSessionData();
        
        // ✅ Load updated data
        await Future.wait([
          loadTeachingSchedule(),
          loadAttendanceHistory(),
          loadAttendanceStats(),
        ]);
        
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error creating learning session: $e');
      return false;
    } finally {
      _isCreatingSession = false;
      notifyListeners();
    }
  }

  // Update attendance status (existing...)
  Future<bool> updateAttendanceStatus(int id, String status, String? keterangan) async {
    _isUpdatingAttendance = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateAttendanceStatus(id, status, keterangan);
      
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

  // Load metadata untuk filter (existing...)
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

  // ✅ ENHANCED: Check and update session status with persistence
  Future<void> checkSessionStatus() async {
    try {
      final now = DateTime.now();
      final toRemove = <int>{};
      
      for (final sessionId in _activeSessionIds) {
        final sessionData = _sessionData[sessionId];
        if (sessionData != null) {
          final endTimeParts = sessionData.jamSelesai.split(':');
          final endTime = DateTime(
            now.year, now.month, now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );
          
          if (now.isAfter(endTime)) {
            toRemove.add(sessionId);
            _completedSessionIds.add(sessionId);
          }
        }
      }
      
      _activeSessionIds.removeAll(toRemove);
      _lastSessionCheck = now;
      
      if (toRemove.isNotEmpty) {
        await _saveSessionData(); // ✅ Save updated state
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking session status: $e');
    }
  }

  // ✅ ENHANCED: Clear session data (for logout) with storage cleanup
  Future<void> clearSessionData() async {
    await _clearSessionData();
    notifyListeners();
  }

  // Get attendance by ID (existing...)
  Future<AttendanceRecordModel?> getAttendanceById(int id) async {
    try {
      return await _repository.getAttendanceById(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error getting attendance by ID: $e');
      return null;
    }
  }

  // Filter methods (existing...)
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

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

  // Apply filters (existing...)
  void _applyFilters() {
    _filteredAttendance = _attendanceHistory.where((record) {
      bool matchDateRange = true;
      bool matchSubject = true;
      bool matchClass = true;
      bool matchStatus = true;

      if (_selectedDate != null) {
        matchDateRange = record.tanggal.year == _selectedDate!.year &&
                       record.tanggal.month == _selectedDate!.month &&
                       record.tanggal.day == _selectedDate!.day;
      } else if (_startDate != null && _endDate != null) {
        matchDateRange = record.tanggal.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                       record.tanggal.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      if (_selectedSubject != null && _selectedSubject!.isNotEmpty) {
        matchSubject = record.namaMapel.toLowerCase() == _selectedSubject!.toLowerCase();
      }

      if (_selectedClass != null && _selectedClass!.isNotEmpty) {
        matchClass = record.namaKelas.toLowerCase() == _selectedClass!.toLowerCase();
      }

      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        matchStatus = record.status.toLowerCase() == _selectedStatus!.toLowerCase();
      }

      return matchDateRange && matchSubject && matchClass && matchStatus;
    }).toList();
  }

  List<TeachingScheduleModel> getSchedulesByDay(String day) {
    return _teachingSchedule.where((schedule) {
      final scheduleDay = _normalizeDay(schedule.hari);
      final filterDay = _normalizeDay(day);
      return scheduleDay == filterDay;
    }).toList();
  }

  // Load all data (existing...)
  Future<void> loadAllData() async {
    await Future.wait([
      loadTeachingSchedule(),
      loadAttendanceHistory(),
      loadAttendanceStats(),
      loadFilterMetadata(),
    ]);
  }

  // ✅ ENHANCED: Refresh all data with session check
  Future<void> refreshData() async {
    await checkSessionStatus();
    await loadAllData();
  }

  // Clear error (existing...)
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods (existing...)
  bool get hasFiltersApplied => 
      _selectedDate != null || 
      (_selectedSubject != null && _selectedSubject!.isNotEmpty) ||
      (_selectedClass != null && _selectedClass!.isNotEmpty) ||
      (_selectedStatus != null && _selectedStatus!.isNotEmpty);

  int get totalFilteredRecords => _filteredAttendance.length;

  AttendanceRecordModel? getFilteredAttendanceById(int id) {
    try {
      return _filteredAttendance.firstWhere((record) => record.idAbsensi == id);
    } catch (e) {
      return null;
    }
  }

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
        
        return nowMinutes >= (startMinutes - 30) && nowMinutes <= endMinutes;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Existing methods untuk compatibility...
  Future<Map<String, List<double>>> getAttendanceTrend() async {
    try {
      final now = DateTime.now();
      final result = <String, List<double>>{
        'attendance': [],
        'dates': [],
      };
      
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

  bool isScheduleToday(dynamic schedule) {
    if (schedule == null) return false;
    
    final now = DateTime.now();
    final dayNames = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
    final today = dayNames[now.weekday % 7];
    
    return schedule.hari.toLowerCase() == today.toLowerCase();
  }
}