import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import '../models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final Dio _dio;
  String? _lastVerifiedOtp;

  AuthService._internal() {
    _dio = DioClient().dio;
  }

  factory AuthService() => _instance;

  // ✅ LOGIN - Simple and clean
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      debugPrint('🚀 AuthService: Attempting login for ${request.username}');
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      debugPrint('✅ AuthService: Login response received');
      
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      }
      throw Exception('Login failed: Invalid response');
    } on DioException catch (e) {
      debugPrint('❌ AuthService: Login failed - ${e.message}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Username atau password salah');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError);
        }
      }
      throw Exception('Terjadi kesalahan. Silakan coba lagi nanti.');
    }
  }

  // ✅ REGISTER - Simple
  Future<bool> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError);
        }
      } else if (e.response?.statusCode == 409) {
        throw Exception('Email sudah terdaftar');
      }
      throw Exception('Registrasi gagal');
    }
  }

  // ✅ FORGOT PASSWORD
  Future<bool> requestPasswordReset(PasswordResetRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Email tidak terdaftar');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Format email tidak valid');
      }
      throw Exception('Gagal mengirim OTP');
    }
  }

  // ✅ VERIFY OTP
  Future<bool> verifyOtp(OtpVerificationRequest request) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.verifyOtp}/${request.otp}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        _lastVerifiedOtp = request.otp;
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Kode OTP tidak valid atau sudah kadaluarsa');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email tidak terdaftar');
      }
      throw Exception('Kode OTP tidak valid');
    }
  }

  // ✅ RESET PASSWORD
  Future<bool> resetPassword(PasswordChangeRequest request) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.resetPassword}/$_lastVerifiedOtp',
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi reset password sudah kadaluarsa');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Password tidak memenuhi kriteria');
      }
      throw Exception('Gagal mengubah password');
    }
  }
}