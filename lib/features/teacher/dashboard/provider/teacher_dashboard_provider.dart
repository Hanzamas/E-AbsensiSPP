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
  Map<String, dynamic> _attendanceData = {};
  Map<String, int> _attendanceStats = {};
  String? _error;
  
  // Filter states
  int? _selectedClassId; // New: Track selected class ID for filtering

  // Getters
  bool get isLoading => _isLoading;
  bool get isStartingSession => _isStartingSession;
  UserProfileModel? get userProfile => _userProfile;
  List<ScheduleModel> get todaySchedule => _todaySchedule;
  Map<String, int> get attendanceStats => _filteredAttendanceStats;
  String? get error => _error;
  int? get selectedClassId => _selectedClassId;

  // Get today's classes for the filter dropdown
  List<ScheduleModel> get todayClasses => _todaySchedule;
  
  // Get filtered attendance stats based on selected class
  Map<String, int> get _filteredAttendanceStats {
    if (_selectedClassId == null) {
      return _attendanceStats; // Return all stats if no filter
    }
    
    // Filter attendance data by selected class and recalculate stats
    final filteredData = _attendanceData.entries
        .where((entry) => entry.value['classId'] == _selectedClassId)
        .map((e) => e.value)
        .toList();
    
    if (filteredData.isEmpty) {
      return {
        'total': 0,
        'hadir': 0,
        'alpha': 0, 
        'sakit': 0,
        'izin': 0
      };
    }
    
    // Count statuses
    int total = filteredData.length;
    int hadir = filteredData.where((item) => item['status'] == 'Hadir').length;
    int alpha = filteredData.where((item) => item['status'] == 'Alpha').length;
    int sakit = filteredData.where((item) => item['status'] == 'Sakit').length;
    int izin = filteredData.where((item) => item['status'] == 'Izin').length;
    
    return {
      'total': total,
      'hadir': hadir,
      'alpha': alpha,
      'sakit': sakit,
      'izin': izin
    };
  }

  // Select a class for filtering
  void selectClass(int? classId) {
    _selectedClassId = classId;
    notifyListeners();
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
        _repository.getAttendanceData(),
      ]);

      _userProfile = results[0] as UserProfileModel;
      _todaySchedule = results[1] as List<ScheduleModel>;
      
      // Process attendance data
      final attendanceData = results[2] as List<dynamic>;
      _processAttendanceData(attendanceData);
      
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Dashboard Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process attendance data and create stats
  void _processAttendanceData(List<dynamic> attendanceData) {
    // Reset data
    _attendanceData = {};
    
    // Process raw data into structured format with mapping to classes
    for (final item in attendanceData) {
      final String id = item['id_absensi']?.toString() ?? '';
      final int? classId = _getClassIdByName(item['nama_kelas']);
      
      if (id.isNotEmpty) {
        _attendanceData[id] = {
          'id': id,
          'mapel': item['nama_mapel'] ?? '',
          'kelas': item['nama_kelas'] ?? '',
          'classId': classId,
          'tanggal': item['tanggal'] ?? '',
          'status': item['status'] ?? 'Alpha',
          'waktuScan': item['waktu_scan'],
          'nis': item['nis'] ?? '',
          'namaSiswa': item['nama_siswa'] ?? '',
        };
      }
    }
    
    // Calculate overall stats
    int total = _attendanceData.length;
    int hadir = _attendanceData.values.where((item) => item['status'] == 'Hadir').length;
    int alpha = _attendanceData.values.where((item) => item['status'] == 'Alpha').length;
    int sakit = _attendanceData.values.where((item) => item['status'] == 'Sakit').length;
    int izin = _attendanceData.values.where((item) => item['status'] == 'Izin').length;
    
    _attendanceStats = {
      'total': total,
      'hadir': hadir,
      'alpha': alpha,
      'sakit': sakit,
      'izin': izin
    };
  }
  
  // Helper to find class ID by name
  int? _getClassIdByName(String? className) {
    if (className == null) return null;
    
    final matchingClass = _todaySchedule.firstWhere(
      (schedule) => schedule.namaKelas == className,
      orElse: () => ScheduleModel(
        id: 0, idGuru: 0, idMapel: 0, idKelas: 0,
        hari: '', jamMulai: '', jamSelesai: '',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
        namaGuru: '', namaMapel: '', namaKelas: '', tahunAjaran: '',
      ),
    );
    
    return matchingClass.id != 0 ? matchingClass.idKelas : null;
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