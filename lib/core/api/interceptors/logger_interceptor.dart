import 'package:dio/dio.dart';

// core/api/interceptors/logger_interceptor.dart
class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌── Request ──────────────────────────────');
    print('│ ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌── Response ─────────────────────────────');
    print('│ ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌── Error ────────────────────────────────');
    print('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('│ ${err.message}');
    if (err.response?.data != null) {
      print('│ Error Data: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────');
    return handler.next(err);
  }
}
