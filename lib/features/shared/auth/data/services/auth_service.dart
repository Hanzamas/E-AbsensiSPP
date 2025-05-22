import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/features/shared/auth/data/models/auth_models.dart';
// import 'models/forgot_password_response.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final Dio _dio;
  // String? _otpToken;  // Untuk menyimpan token OTP
  String? _lastVerifiedOtp;

  // Private constructor
  AuthService._internal() {
    _dio = DioClient().dio;
  }

  // Singleton factory
  factory AuthService() => _instance;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'Username atau password salah';
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        throw errors.values.first[0] as String;
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': 'siswa'
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      throw 'Registrasi gagal';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw firstError.first.toString();
        }
        throw 'Validasi gagal';
      } else if (e.response?.statusCode == 409) {
        throw 'Email sudah terdaftar';
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] as String?;
        throw message ?? 'Registrasi gagal';
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw 'Gagal mengirim kode OTP';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw firstError.first.toString();
        }
        throw 'Email tidak valid';
      } else if (e.response?.statusCode == 404) {
        throw 'Email tidak terdaftar';
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.verifyOtp}/$otp',
        data: {'otp': otp},
      );

      if (response.statusCode == 200) {
        _lastVerifiedOtp = otp;
        return true;
      }
      throw 'Kode OTP tidak valid';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw firstError.first.toString();
        }
        throw 'Kode OTP tidak valid';
      } else if (e.response?.statusCode == 404) {
        throw 'Email tidak terdaftar';
      } else if (e.response?.statusCode == 401) {
        throw 'Kode OTP tidak valid atau sudah kadaluarsa';
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.resetPassword}/$_lastVerifiedOtp',
        data: {
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw 'Gagal mengubah password';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw firstError.first.toString();
        }
        throw 'Password tidak memenuhi kriteria';
      } else if (e.response?.statusCode == 404) {
        throw 'Email tidak terdaftar';
      } else if (e.response?.statusCode == 401) {
        throw 'Sesi reset password sudah kadaluarsa. Silakan memulai proses dari awal.';
      }
      throw 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }
} 