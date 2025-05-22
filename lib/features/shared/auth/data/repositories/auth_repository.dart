import 'package:e_absensi/features/shared/auth/data/models/auth_models.dart';
import 'package:e_absensi/features/shared/auth/data/services/auth_service.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  late final AuthService _authService;

  // Private constructor
  AuthRepository._internal() {
    _authService = AuthService();
  }

  // Singleton factory
  factory AuthRepository() => _instance;

  Future<LoginResponse> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      return await _authService.login(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.register(username, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      return await _authService.requestPasswordReset(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      return await _authService.verifyOtp(email, otp);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      return await _authService.resetPassword(email, newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
