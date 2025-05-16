import 'package:dio/dio.dart';
import '../api_endpoints.dart';
import '../dio_client.dart';

class ScheduleService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getStudentSchedule() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudentSchedule);
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