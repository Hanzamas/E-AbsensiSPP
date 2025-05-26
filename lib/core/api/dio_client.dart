// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/auth_interceptor.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          // 'Content-Type': 'application/json',
        },
      ),
    );

    // Hanya gunakan auth interceptor
    dio.interceptors.add(AuthInterceptor());
  }
}