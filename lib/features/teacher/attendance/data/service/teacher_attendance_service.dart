import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class TeacherAttendanceService {
  final Dio _dio = DioClient().dio;

  /// GET /teacher/teaching/my - Get teaching schedule
  Future<List<dynamic>> getTeachingSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTeacherSchedule);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil jadwal mengajar');
      }
    } catch (e) {
      throw Exception('Error getTeachingSchedule: $e');
    }
  }

  /// POST /teacher/learning-session/assign - Create learning session
  Future<Map<String, dynamic>> createLearningSession(int idPengajaran) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createLearningSession,
        data: {'id_pengajaran': idPengajaran},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat sesi pembelajaran');
      }
    } catch (e) {
      throw Exception('Error createLearningSession: $e');
    }
  }

  /// GET /teacher/attendance - Get attendance history
  Future<List<dynamic>> getAttendanceHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTeacherAttendance);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil riwayat absensi');
      }
    } catch (e) {
      throw Exception('Error getAttendanceHistory: $e');
    }
  }

  /// GET /teacher/attendance/:id - Get attendance detail by ID
  Future<Map<String, dynamic>> getAttendanceById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getTeacherAttendanceById}/$id');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil detail absensi');
      }
    } catch (e) {
      throw Exception('Error getAttendanceById: $e');
    }
  }

  /// PUT /teachers/attendance/update/:id - Update attendance status
  Future<Map<String, dynamic>> updateAttendanceStatus(
    int id, 
    String status, 
    String? keterangan
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateTeacherAttendance}/$id',
        data: {
          'status': status,
          'keterangan': keterangan,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal update status absensi');
      }
    } catch (e) {
      throw Exception('Error updateAttendanceStatus: $e');
    }
  }
}