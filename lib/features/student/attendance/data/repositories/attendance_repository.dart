import '../services/attendance_service.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  static final AttendanceRepository _instance = AttendanceRepository._internal();
  late final AttendanceService _service;

  // Private constructor
  AttendanceRepository._internal() {
    _service = AttendanceService();
  }

  // Singleton factory
  factory AttendanceRepository() => _instance;

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    try {
      final response = await _service.getAttendanceHistory();
      
      if (response['status'] == true) {
        final List<dynamic> list = response['data'] ?? [];
        
        if (list.isEmpty) {
          return [];
        }
        
        return list.map((item) => AttendanceModel.fromJson(item)).toList();
      } else {
        throw Exception(response['message'] ?? 'Gagal memuat riwayat absensi');
      }
    } catch (e) {
      throw Exception('Gagal memuat riwayat absensi: $e');
    }
  }

  Future<Map<String, dynamic>> submitAttendance(String qrCode) async {
    try {
      final response = await _service.submitAttendance(qrCode);
      
      if (response['status'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Gagal melakukan absensi');
      }
    } catch (e) {
      throw Exception('Gagal melakukan absensi: $e');
    }
  }
} 