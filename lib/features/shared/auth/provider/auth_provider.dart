import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';
import 'package:e_absensi/features/shared/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../data/services/auth_service.dart';
// import '../data/models/login_request.dart';
import 'package:e_absensi/features/shared/auth/data/models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  
  late final SecureStorage _storage;
  late final AuthRepository _authRepository;
  String? _token;
  String? _userRole;

  // Private constructor
  AuthProvider._internal() {
    _storage = SecureStorage();
    _authRepository = AuthRepository();
  }

  // Singleton factory
  factory AuthProvider() => _instance;

  String? get userRole => _userRole;
  bool get isAuthenticated => _token != null;

  Future<String?> checkAuth() async {
    _token = await _storage.read('token');
    _userRole = await _storage.read('user_role');
    return _userRole;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _authRepository.login(username, password);
      await _storage.write('token', response.data.token);
      await _storage.write('user_role', response.data.role.toLowerCase());
      _token = response.data.token;
      _userRole = response.data.role.toLowerCase();
      notifyListeners();
      return response.status;
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
      return await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Bersihkan SharedPreferences
        final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Hapus data dari secure storage
      await _storage.clearAll();
      
      // Reset state
      _token = null;
      _userRole = null;
      
      notifyListeners();
    } catch (e) {
      // Pastikan state direset meskipun ada error
      _token = null;
      _userRole = null;
      notifyListeners();
      rethrow;
    }
  }

  // Method untuk request reset password
  Future<bool> requestPasswordReset(String email) async {
    try {
      return await _authRepository.requestPasswordReset(email);
    } catch (e) {
      rethrow;
    }
  }

  // Method untuk verifikasi OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      return await _authRepository.verifyOtp(email, otp);
    } catch (e) {
      rethrow;
    }
  }

  // Method untuk reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      return await _authRepository.resetPassword(email, newPassword);
    } catch (e) {
      rethrow;
    }
  }
} 