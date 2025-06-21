import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import '../data/repository/teacher_attendance_repository.dart';
import '../data/model/teaching_schedule_model.dart';
import '../data/model/learning_session_model.dart';
import '../data/model/attendance_record_model.dart';

class TeacherAttendanceProvider with ChangeNotifier {
  final TeacherAttendanceRepository _repository = TeacherAttendanceRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Loading states
  bool _isLoading = false;
  bool _isCreatingSession = false;
  bool _isUpdatingAttendance = false;
  bool _isLoadingStats = false;
  
  // ✅ NEW: Session management with persistence using 'active_learning_session' key
  LearningSessionModel? _activeSession;
  Timer? _sessionCheckTimer;
  
  // Data states
  List<TeachingScheduleModel> _teachingSchedule = [];
  List<AttendanceRecordModel> _attendanceHistory = [];
  List<AttendanceRecordModel> _filteredAttendance = [];
  Map<String, int> _attendanceStats = {};
  String? _error;
  
  // Filter states
  DateTime? _selectedDate;
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedStatus;
  List<String> _availableSubjects = [];
  List<String> _availableClasses = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCreatingSession => _isCreatingSession;
  bool get isUpdatingAttendance => _isUpdatingAttendance;
  bool get isLoadingStats => _isLoadingStats;
  List<String> get availableSubjects => _availableSubjects;
  List<String> get availableClasses => _availableClasses;
  
  List<TeachingScheduleModel> get teachingSchedule => _teachingSchedule;
  List<AttendanceRecordModel> get attendanceHistory => _attendanceHistory;
  List<AttendanceRecordModel> get filteredAttendance => _filteredAttendance;
  Map<String, int> get attendanceStats => _attendanceStats;
  String? get error => _error;
  
  DateTime? get selectedDate => _selectedDate;
  String? get selectedSubject => _selectedSubject;
  String? get selectedClass => _selectedClass;
  String? get selectedStatus => _selectedStatus;

  // ✅ NEW: Session state getters
  LearningSessionModel? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null && _isSessionStillValid();
  
  bool isSessionActive(int scheduleId) {
    return _activeSession?.idPengajaran == scheduleId && hasActiveSession;
  }
  
  bool isSessionCompleted(int scheduleId) {
    return _activeSession?.idPengajaran == scheduleId && !_isSessionStillValid();
  }

  // ✅ NEW: Save active session to storage
  Future<void> _saveActiveSession(LearningSessionModel session) async {
    try {
      final sessionData = {
        'id_sesi': session.idSesi,
        'id_pengajaran': session.idPengajaran,
        'qr_token': session.qrToken,
        'date': session.date,
        'jam_mulai': session.jamMulai,
        'jam_selesai': session.jamSelesai,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _storage.write(
        key: 'active_learning_session',
        value: jsonEncode(sessionData),
      );
      
      debugPrint('✅ Session saved to storage: ${session.qrToken}');
    } catch (e) {
      debugPrint('❌ Error saving session: $e');
    }
  }

  // ✅ NEW: Load active session from storage
  Future<void> loadActiveSession() async {
    try {
      final sessionString = await _storage.read(key: 'active_learning_session');
      
      if (sessionString != null) {
        final sessionData = jsonDecode(sessionString);
        
        // ✅ Check if session is still valid (not expired)
        if (_isSessionDataValid(sessionData)) {
          _activeSession = LearningSessionModel(
            idSesi: sessionData['id_sesi'],
            idPengajaran: sessionData['id_pengajaran'],
            qrToken: sessionData['qr_token'],
            date: sessionData['date'],
            jamMulai: sessionData['jam_mulai'],
            jamSelesai: sessionData['jam_selesai'],
          );
          
          debugPrint('✅ Active session restored: ${_activeSession!.qrToken}');
          
          // ✅ Start monitoring
          _startSessionMonitoring();
          notifyListeners();
        } else {
          // ✅ Session expired, clear it
          await _clearActiveSession();
          debugPrint('⏰ Session expired, cleared from storage');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading active session: $e');
      await _clearActiveSession();
    }
  }

  // ✅ NEW: Check if session data is still valid
  bool _isSessionDataValid(Map<String, dynamic> sessionData) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sessionDate = DateTime.parse(sessionData['date']);
      
      // ✅ Check if session is for today
      if (!_isSameDay(today, sessionDate)) {
        return false;
      }
      
      // ✅ Check if current time is before session end time
      final endTimeParts = sessionData['jam_selesai'].split(':');
      final endTime = DateTime(
        now.year, now.month, now.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );
      
      return now.isBefore(endTime);
    } catch (e) {
      debugPrint('❌ Error checking session validity: $e');
      return false;
    }
  }

  // ✅ NEW: Check if current session is still valid
  bool _isSessionStillValid() {
    if (_activeSession == null) return false;
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sessionDate = DateTime.parse(_activeSession!.date);
      
      // Check if session is for today
      if (!_isSameDay(today, sessionDate)) {
        return false;
      }
      
      // Check if current time is before session end time
      final endTimeParts = _activeSession!.jamSelesai.split(':');
      final endTime = DateTime(
        now.year, now.month, now.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );
      
      return now.isBefore(endTime);
    } catch (e) {
      debugPrint('❌ Error checking session validity: $e');
      return false;
    }
  }

  // ✅ NEW: Helper method to check same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // ✅ NEW: Clear active session from storage
  Future<void> _clearActiveSession() async {
    try {
      await _storage.delete(key: 'active_learning_session');
      _activeSession = null;
      _stopSessionMonitoring();
      debugPrint('✅ Active session cleared from storage');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error clearing active session: $e');
    }
  }

  // ✅ NEW: Start session monitoring timer
  void _startSessionMonitoring() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 1), // Check every minute
      (timer) => _checkSessionExpiry(),
    );
    debugPrint('✅ Session monitoring started');
  }

  // ✅ NEW: Stop session monitoring timer
  void _stopSessionMonitoring() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
    debugPrint('🛑 Session monitoring stopped');
  }

  // ✅ NEW: Auto-check session expiry
  Future<void> _checkSessionExpiry() async {
    if (_activeSession != null && !_isSessionStillValid()) {
      await _clearActiveSession();
      debugPrint('⏰ Session auto-expired and cleared');
    }
  }

  // ✅ ENHANCED: Create learning session with persistence
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
        // ✅ Set active session
        _activeSession = result;
        
        // ✅ Save to storage for persistence
        await _saveActiveSession(result);
        
        // ✅ Start monitoring
        _startSessionMonitoring();
        
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

  // ✅ ENHANCED: Load teaching schedule with session restoration
  Future<void> loadTeachingSchedule() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teachingSchedule = await _repository.getTeachingSchedule();
      
      // ✅ Load any active session from storage
      await loadActiveSession();
      
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading teaching schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Reset provider to initial state
  void resetToInitialState() {
    try {
      debugPrint('🔄 TeacherAttendanceProvider: Resetting to initial state...');
      
      // Stop monitoring
      _stopSessionMonitoring();
      
      // Reset data
      _teachingSchedule = [];
      _attendanceHistory = [];
      _filteredAttendance = [];
      _attendanceStats = {};
      _availableSubjects = [];
      _availableClasses = [];
      _activeSession = null;
      
      // Reset states
      _isLoading = false;
      _isCreatingSession = false;
      _isUpdatingAttendance = false;
      _isLoadingStats = false;
      _error = null;
      _selectedDate = null;
      _selectedSubject = null;
      _selectedClass = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      
      debugPrint('✅ TeacherAttendanceProvider: Reset complete');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ TeacherAttendanceProvider: Reset error - $e');
    }
  }

  @override
  void dispose() {
    _stopSessionMonitoring();
    super.dispose();
  }

  // ✅ Load all data with session monitoring
  Future<void> loadAllData() async {
    await Future.wait([
      loadTeachingSchedule(),
      loadAttendanceHistory(),
      loadAttendanceStats(),
      loadFilterMetadata(),
    ]);
  }

  // ✅ Refresh all data with session check
  Future<void> refreshData() async {
    await _checkSessionExpiry();
    await loadAllData();
  }

  // ... rest of existing methods (load methods, filters, etc.) remain the same ...
  
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

  // Update attendance status
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

  // Apply filters
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods
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

  // Helper methods
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

  List<TeachingScheduleModel> getSchedulesByDay(String day) {
    return _teachingSchedule.where((schedule) {
      final scheduleDay = _normalizeDay(schedule.hari);
      final filterDay = _normalizeDay(day);
      return scheduleDay == filterDay;
    }).toList();
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