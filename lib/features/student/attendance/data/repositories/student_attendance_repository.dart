import '../services/student_attendance_service.dart';
import '../models/attendance_model.dart';
import '../models/schedule_model.dart';

class StudentAttendanceRepository {
  static final StudentAttendanceRepository _instance = StudentAttendanceRepository._internal();
  late final StudentAttendanceService _service;

  // Private constructor
  StudentAttendanceRepository._internal() {
    _service = StudentAttendanceService();
  }

  // Singleton factory
  factory StudentAttendanceRepository() => _instance;

  // Get attendance history
  Future<List<AttendanceModel>> getAttendanceHistory({
    String? mapel,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _service.getAttendanceHistory(
        mapel: mapel,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  // Get schedules
  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _service.getStudentSchedule();
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ScheduleModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  // ✅ FIXED: Scan QR Code method
  Future<Map<String, dynamic>> scanQRCode(String qrToken) async {
    try {
      final response = await _service.scanQRCode(qrToken);
      
      if (response['status'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Gagal melakukan absensi');
      }
    } catch (e) {
      throw Exception('Gagal melakukan absensi: $e');
    }
  }

  // ✅ SIMPLIFIED: Direct download without complex logic
  Future<String> downloadExcel() async {
    try {
      return await _service.downloadAttendanceExcel();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

} 