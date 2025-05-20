import 'models/login_request.dart';
import 'models/login_response.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<LoginResponse> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);
      return await _authService.login(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
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
