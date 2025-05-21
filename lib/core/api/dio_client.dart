import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/interceptors/auth_interceptor.dart';
import 'package:e_absensi/core/api/interceptors/logger_interceptor.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/config/api_config.dart';

// core/api/dio_client.dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Tambahkan interceptors langsung
    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggerInterceptor(),
    ]);
  }
}
