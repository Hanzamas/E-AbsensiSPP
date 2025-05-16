import 'package:dio/dio.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // print('REQUEST[${options.method}] => PATH: ${options.path}');
    // print('Headers: ${options.headers}');
    // print('Data: ${options.data}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    // print('Data: ${response.data}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    // print('Message: ${err.message}');
    // if (err.response != null) {
    //   print('Error Data: ${err.response?.data}');
    // }
    return handler.next(err);
  }
}
