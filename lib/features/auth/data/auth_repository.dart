import '../models/auth_model.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      return AuthModel.fromJson(response);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      await _authService.verifyOtp(otp);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> resetPassword(String otp, String newPassword, String confirmPassword) async {
    try {
      await _authService.resetPassword(otp, newPassword, confirmPassword);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AuthModel> getUserData() async {
    try {
      final userData = await _authService.getUserData();
      return AuthModel.fromJson(userData);
    } catch (e) {
      throw e.toString();
    }
  }
}
