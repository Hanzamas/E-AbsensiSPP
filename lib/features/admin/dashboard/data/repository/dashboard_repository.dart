// lib/features/admin/dashboard/data/repositories/dashboard_repository.dart

import '../models/attendance_record_model.dart';
import '../models/spp_record_model.dart';
import '../services/report_service.dart';

class DashboardRepository {
  final ReportService _service = ReportService();

  Future<List<AttendanceRecord>> fetchAllAttendanceRecords() {
    return _service.getAllAttendanceRecords();
  }

  Future<List<SppRecord>> fetchAllSppRecords() {
    return _service.getAllSppRecords();
  }
}