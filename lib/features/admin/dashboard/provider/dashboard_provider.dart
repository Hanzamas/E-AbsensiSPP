// lib/features/admin/dashboard/provider/dashboard_provider.dart

import 'package:flutter/material.dart';
import 'package:e_absensi/features/admin/users/data/models/student_model.dart';
import 'package:e_absensi/features/admin/users/data/repositories/student_repository.dart';
import '../data/models/attendance_record_model.dart';
import '../data/models/spp_record_model.dart';
import '../data/repository/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  final StudentRepository _studentRepo = StudentRepository();
  final DashboardRepository _dashboardRepo = DashboardRepository();

  bool _isLoading = false;
  String? _error;
  List<Student> _students = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<SppRecord> _sppRecords = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalStudents => _students.length;
  
  int get totalPresent => _attendanceRecords.where((r) => r.status.toLowerCase() == 'hadir').length;
  int get totalAlpha => _attendanceRecords.where((r) => r.status.toLowerCase() == 'alpha').length;
  int get totalSickOrPermit => _attendanceRecords.where((r) => ['sakit', 'izin'].contains(r.status.toLowerCase())).length;

  int get totalSppPaid => _sppRecords.where((r) => r.statusBill.toLowerCase() == 'lunas').length;
  int get totalSppUnpaid => _sppRecords.where((r) => r.statusBill.toLowerCase() == 'terhutang').length;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _studentRepo.getStudents(),
        _dashboardRepo.fetchAllAttendanceRecords(),
        _dashboardRepo.fetchAllSppRecords(),
      ]);

      _students = results[0] as List<Student>;
      _attendanceRecords = results[1] as List<AttendanceRecord>;
      _sppRecords = results[2] as List<SppRecord>;
      
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}