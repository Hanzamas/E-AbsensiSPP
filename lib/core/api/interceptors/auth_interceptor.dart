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
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired atau invalid
      await _storage.delete('token');
      await _storage.delete('user_role');
      await _storage.delete('user_data');
      // Bisa tambahkan logic untuk refresh token atau logout
    }
    return handler.next(err);
  }
}
