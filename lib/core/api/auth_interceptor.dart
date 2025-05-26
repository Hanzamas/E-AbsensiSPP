// lib/core/api/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final _storage = SecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read('token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired, hapus data auth
      _storage.clearAll();
    }
    handler.next(err);
  }
}