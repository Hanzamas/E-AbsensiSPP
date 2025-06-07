import 'package:flutter/material.dart';
import '../data/models/attendance_model.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/student_attendance_repository.dart';
import '../data/models/schedule_model.dart';

class StudentAttendanceProvider extends ChangeNotifier {
  static final StudentAttendanceProvider _instance = StudentAttendanceProvider._internal();
  final StudentAttendanceRepository _repository = StudentAttendanceRepository();
  // Private constructor
  StudentAttendanceProvider._internal();

  // Singleton factory
  factory StudentAttendanceProvider() => _instance;

    // Loading states
  bool _isLoading = false;
  bool _isLoadingSchedule = false;
  bool _isScanning = false;
  bool _isDownloading = false;
  String? _error;

    // Data
  List<AttendanceModel> _attendanceHistory = [];
  List<ScheduleModel> _schedules = [];
  Map<String, dynamic>? _submissionResult;

    // Filter states
  String? _selectedMapel;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;


  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingSchedule => _isLoadingSchedule;
  bool get isScanning => _isScanning;
    bool get isDownloading => _isDownloading;
  String? get error => _error;
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;
  List<ScheduleModel> get schedules => _schedules;
  String? get selectedMapel => _selectedMapel;
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, dynamic>? get submissionResult => _submissionResult;


    // Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadAttendanceHistory(),
      loadSchedules(),
    ]);
  }

  // Load attendance history with filters
  Future<void> loadAttendanceHistory() async {
    try {
      _setLoading(true);
      _error = null;

      final result = await _repository.getAttendanceHistory(
        mapel: _selectedMapel,
        status: _selectedStatus,
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
      );

      _attendanceHistory = result;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading attendance history: $e');
    } finally {
      _setLoading(false);
    }
  }

    // Load schedules
  Future<void> loadSchedules() async {
    try {
      _setLoadingSchedule(true);
      final result = await _repository.getSchedules();
      _schedules = result;
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    } finally {
      _setLoadingSchedule(false);
    }
  }

  // Scan QR Code
  Future<bool> scanQRCode(String qrToken) async {
    try {
      _setScanning(true);
      _error = null;

      await _repository.scanQRCode(qrToken);
      
      // Refresh attendance history after successful scan
      await loadAttendanceHistory();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error scanning QR code: $e');
      return false;
    } finally {
      _setScanning(false);
    }
  }

  // Filter methods
  void setMapelFilter(String? mapel) {
    _selectedMapel = mapel;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedMapel = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Apply filters
  Future<void> applyFilters() async {
    await loadAttendanceHistory();
  }

  // ✅ IMPROVED: Download Excel with better debugging
  Future<String?> downloadExcel() async {
    if (_isDownloading) return null;
    
    try {
      _setDownloading(true);
      _error = null;
      
      debugPrint('🔍 Starting Excel download...');
      
      final filePath = await _repository.downloadExcel();
      
      debugPrint('🔍 Excel download successful: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('🔍 Excel download error: $e');
      _error = e.toString();
      
      // ✅ More specific error handling
      if (e.toString().contains('403') || e.toString().contains('Akses ditolak')) {
        _error = 'Akses ditolak - silakan logout dan login kembali';
      } else if (e.toString().contains('404') || e.toString().contains('tidak ditemukan')) {
        _error = 'Fitur download belum tersedia di server';
      } else if (e.toString().contains('401') || e.toString().contains('Token tidak valid')) {
        _error = 'Sesi Anda telah berakhir, silakan login kembali';
      } else if (e.toString().contains('500') || e.toString().contains('Server error')) {
        _error = 'Server sedang bermasalah, coba lagi nanti';
      } else if (e.toString().contains('timeout')) {
        _error = 'Download timeout - periksa koneksi internet';
      } else {
        _error = 'Gagal download file: ${e.toString().replaceAll('Exception: ', '')}';
      }
      
      return null;
    } finally {
      _setDownloading(false);
    }
  }

  // Statistics calculations
  Map<String, int> getAttendanceStats() {
    final stats = {
      'total': _attendanceHistory.length,
      'hadir': 0,
      'alpha': 0,
      'sakit': 0,
      'izin': 0,
    };

    for (final attendance in _attendanceHistory) {
      switch (attendance.status.toLowerCase()) {
        case 'hadir':
          stats['hadir'] = stats['hadir']! + 1;
          break;
        case 'alpha':
          stats['alpha'] = stats['alpha']! + 1;
          break;
        case 'sakit':
          stats['sakit'] = stats['sakit']! + 1;
          break;
        case 'izin':
          stats['izin'] = stats['izin']! + 1;
          break;
      }
    }

    return stats;
  }

  // ✅ REAL Get attendance status for schedule
  String getAttendanceStatusForSchedule(ScheduleModel schedule) {
    final today = DateTime.now();
    final todayFormatted = today.toIso8601String().split('T')[0];
    
    // Cari attendance untuk schedule hari ini
    final attendance = _attendanceHistory.where((a) {
      final attendanceDate = a.tanggal.toIso8601String().split('T')[0];
      return a.namaMapel == schedule.mapel && 
             attendanceDate == todayFormatted;
    }).firstOrNull;
    
    return attendance?.status ?? 'Belum Absen';
  }

  // Get attendance by subject
  Map<String, Map<String, int>> getAttendanceBySubject() {
    final Map<String, Map<String, int>> result = {};

    for (final attendance in _attendanceHistory) {
      final mapel = attendance.namaMapel;
      if (!result.containsKey(mapel)) {
        result[mapel] = {'total': 0, 'hadir': 0, 'alpha': 0, 'sakit': 0, 'izin': 0};
      }

      result[mapel]!['total'] = result[mapel]!['total']! + 1;

      switch (attendance.status.toLowerCase()) {
        case 'hadir':
          result[mapel]!['hadir'] = result[mapel]!['hadir']! + 1;
          break;
        case 'alpha':
          result[mapel]!['alpha'] = result[mapel]!['alpha']! + 1;
          break;
        case 'sakit':
          result[mapel]!['sakit'] = result[mapel]!['sakit']! + 1;
          break;
        case 'izin':
          result[mapel]!['izin'] = result[mapel]!['izin']! + 1;
          break;
      }
    }

    return result;
  }

    // ✅ REAL Get schedules for specific day
  List<ScheduleModel> getSchedulesForDay(String day) {
    if (day == 'today') {
      final today = _getCurrentDay();
      return _schedules.where((s) => s.hari.toLowerCase() == today).toList();
    }
    return _schedules.where((s) => s.hari.toLowerCase() == day).toList();
  }

  // ✅ REAL Get available subjects for filter
  List<String> getAvailableSubjects() {
    final subjects = _attendanceHistory.map((e) => e.namaMapel).toSet().toList();
    subjects.sort();
    return subjects;
  }

  // ✅ REAL Check if can scan QR for schedule
  bool canScanQRForSchedule(ScheduleModel schedule) {
    final status = getAttendanceStatusForSchedule(schedule);
    final now = DateTime.now();
    
    // Parse jam mulai dan selesai
    final startTimeParts = schedule.jamMulai.split(':');
    final endTimeParts = schedule.jamSelesai.split(':');
    
    final startTime = DateTime(
      now.year, now.month, now.day,
      int.parse(startTimeParts[0]), int.parse(startTimeParts[1])
    );
    
    final endTime = DateTime(
      now.year, now.month, now.day,
      int.parse(endTimeParts[0]), int.parse(endTimeParts[1])
    );
    
    // Bisa scan jika status belum absen dan waktu dalam rentang jadwal
    return status == 'Belum Absen' && 
           now.isAfter(startTime) && 
           now.isBefore(endTime);
  }

  // Helper methods
  String _getCurrentDay() {
    final today = DateTime.now().weekday;
    const days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];
    return days[today - 1];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingSchedule(bool value) {
    _isLoadingSchedule = value;
    notifyListeners();
  }

  void _setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  void _setDownloading(bool value) {
    _isDownloading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // // Get available subjects for filter
  // List<String> getAvailableSubjects() {
  //   final subjects = _attendanceHistory.map((e) => e.namaMapel).toSet().toList();
  //   subjects.sort();
  //   return subjects;
  // }

  // // Helper methods
  // void _setLoading(bool value) {
  //   _isLoading = value;
  //   notifyListeners();
  // }

  // void _setLoadingSchedule(bool value) {
  //   _isLoadingSchedule = value;
  //   notifyListeners();
  // }

  // void _setScanning(bool value) {
  //   _isScanning = value;
  //   notifyListeners();
  // }

  // void clearError() {
  //   _error = null;
  //   notifyListeners();
  // }

  // Submit attendance
  Future<bool> submitAttendance(String qrCode) async {
    try {
      _isLoading = true;
      _error = null;
      _submissionResult = null;
      notifyListeners();

      final result = await _repository.submitAttendance(qrCode);
      _submissionResult = result;
      
      // Refresh attendance history after successful submission
      await loadAttendanceHistory();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error submitting attendance: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear submission result
  void clearSubmissionResult() {
    _submissionResult = null;
    notifyListeners();
  }

  // Get submission data
  Map<String, dynamic>? getSubmissionData() {
    return _submissionResult?['data'];
  }

  // Refresh data
  Future<bool> refresh() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _attendanceHistory = await _repository.getAttendanceHistory();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 