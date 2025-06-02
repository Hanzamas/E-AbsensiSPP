import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  late final AuthService _authService;

  AuthRepository._internal() {
    _authService = AuthService();
  }

  factory AuthRepository() => _instance;

  Future<LoginResponse> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);
    return await _authService.login(request);
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = RegisterRequest(
      username: username,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return await _authService.register(request);
  }

  Future<bool> requestPasswordReset(String email) async {
    final request = PasswordResetRequest(email: email);
    return await _authService.requestPasswordReset(request);
  }

  Future<bool> verifyOtp(String otp) async {
    final request = OtpVerificationRequest(otp: otp);
    return await _authService.verifyOtp(request);
  }

  Future<bool> resetPassword(String newPassword) async {
    final request = PasswordChangeRequest(
      newPassword: newPassword,
      confirmPassword: newPassword,
    );
    return await _authService.resetPassword(request);
  }
}