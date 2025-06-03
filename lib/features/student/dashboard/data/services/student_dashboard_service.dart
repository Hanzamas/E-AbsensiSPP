import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class StudentDashboardService {
  final Dio _dio = DioClient().dio;

  /// GET /users/my - Get user profile (Independent)
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

  /// GET /students/schedule - Get student schedule
  Future<List<dynamic>> getStudentSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudentSchedule);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil jadwal');
      }
    } catch (e) {
      throw Exception('Error getStudentSchedule: $e');
    }
  }

  /// GET /studens/attendance/my - Get attendance statistics (derived)
  Future<Map<String, int>> getAttendanceStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudentAttendance);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> attendanceList = response.data['data'] ?? [];
        
        // Calculate stats from attendance data
        int total = attendanceList.length;
        int hadir = attendanceList.where((a) => a['status'] == 'Hadir').length;
        int alpha = attendanceList.where((a) => a['status'] == 'Alpha').length;
        int sakit = attendanceList.where((a) => a['status'] == 'Sakit').length;
        int izin = attendanceList.where((a) => a['status'] == 'Izin').length;
        
        return {
          'total': total,
          'hadir': hadir,
          'alpha': alpha,
          'sakit': sakit,
          'izin': izin,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil statistik kehadiran');
      }
    } catch (e) {
      debugPrint('⚠️ AttendanceStats error (optional): $e');
      // Return default stats instead of throwing error
      return {
        'total': 0,
        'hadir': 0,
        'alpha': 0,
        'sakit': 0,
        'izin': 0,
      };
    }
  }

  /// GET /students/attendance/my with filter - Get attendance statistics for a specific subject
Future<Map<String, int>> getAttendanceStatsBySubject(String? subject) async {
  try {
    // Gunakan parameter query mapel jika ada subject
    final Map<String, dynamic>? queryParams = subject != null 
      ? {'mapel': subject} 
      : null;
    
    final response = await _dio.get(
      ApiEndpoints.getStudentAttendance,
      queryParameters: queryParams
    );
    
    if (response.statusCode == 200 && response.data['status'] == true) {
      final List<dynamic> attendanceList = response.data['data'] ?? [];
      
      // Jika subject null, filter berdasarkan response mapel
      // Jika subject tidak null, data sudah difilter dari server
      final filteredList = subject == null 
        ? attendanceList 
        : attendanceList.where((a) => a['mapel'] == subject).toList();
      
      // Calculate stats from filtered attendance data
      int total = filteredList.length;
      int hadir = filteredList.where((a) => a['status'] == 'Hadir').length;
      int alpha = filteredList.where((a) => a['status'] == 'Alpha').length;
      int sakit = filteredList.where((a) => a['status'] == 'Sakit').length;
      int izin = filteredList.where((a) => a['status'] == 'Izin').length;
      
      return {
        'total': total,
        'hadir': hadir,
        'alpha': alpha,
        'sakit': sakit,
        'izin': izin,
      };
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil statistik kehadiran');
    }
  } catch (e) {
    debugPrint('⚠️ AttendanceStatsBySubject error: $e');
    // Return default stats instead of throwing error
    return {
      'total': 0,
      'hadir': 0,
      'alpha': 0,
      'sakit': 0,
      'izin': 0,
    };
  }
}
}