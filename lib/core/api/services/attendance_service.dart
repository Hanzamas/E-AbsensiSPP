import 'package:dio/dio.dart';
import '../api_endpoints.dart';
import '../dio_client.dart';

class AttendanceService {
  final Dio _dio = DioClient().dio;

  // Student endpoints
  Future<Map<String, dynamic>> getAttendance() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAttendance);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAttendanceHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAttendanceHistory);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAttendanceReport({
    String? startDate,
    String? endDate,
    String? studentId,
    String? classId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAttendanceReport,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (studentId != null) 'student_id': studentId,
          if (classId != null) 'class_id': classId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.getDashboardStats);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
} 