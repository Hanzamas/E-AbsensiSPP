import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class TeacherDashboardService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.usersMy);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mendapatkan profil pengguna');
      }
    } catch (e) {
      throw Exception('Error getUserProfile: $e');
    }
  }

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

  Future<List<dynamic>> getAttendanceData() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTeacherAttendance);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data absensi');
      }
    } catch (e) {
      throw Exception('Error getAttendanceData: $e');
    }
  }

  Future<Map<String, dynamic>> startLearningSession(int idPengajaran) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createLearningSession,
        data: {'id_pengajaran': idPengajaran},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memulai sesi pembelajaran');
      }
    } catch (e) {
      throw Exception('Error startLearningSession: $e');
    }
  }
}