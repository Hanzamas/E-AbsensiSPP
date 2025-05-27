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
    required String passwordConfirmation,
  }) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return await _authService.register(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final request = PasswordResetRequest(email: email);
      return await _authService.requestPasswordReset(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      final request = OtpVerificationRequest(otp: otp);
      return await _authService.verifyOtp(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    try {
      final request = PasswordChangeRequest(
        newPassword: newPassword,
        confirmPassword: newPassword,
      );
      return await _authService.resetPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserInfoResponse> getUserInfo() async {
    try {
      return await _authService.getUserInfo();
    } catch (e) {
      rethrow;
    }
  }
}