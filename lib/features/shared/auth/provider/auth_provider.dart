import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';
import 'package:e_absensi/features/shared/auth/data/repositories/auth_repository.dart';
import 'package:e_absensi/features/shared/auth/data/models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  
  late final SecureStorage _storage;
  late final AuthRepository _authRepository;
  String? _token;
  String? _userRole;
  UserInfo? _userInfo;

  // Private constructor
  AuthProvider._internal() {
    _storage = SecureStorage();
    _authRepository = AuthRepository();
    // _loadCachedUserInfo();
  }

  // Singleton factory
  factory AuthProvider() => _instance;

  // Getters
  String? get userRole => _userRole;
  bool get isAuthenticated => _token != null;
  UserInfo? get userInfo => _userInfo;

  // Method untuk load cached user info
  // Future<void> _loadCachedUserInfo() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userInfoString = prefs.getString('user_info');
  //     if (userInfoString != null) {
  //       _userInfo = UserInfo.fromJson(json.decode(userInfoString));
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     // Ignore error, this is just for caching
  //   }
  // }

  Future<String?> checkAuth() async {
    _token = await _storage.read('token');
    _userRole = await _storage.read('user_role');
    notifyListeners();
    return _userRole;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _authRepository.login(username, password);
      
      await _storage.write('token', response.data.token);
      await _storage.write('user_role', response.data.role.toLowerCase());
      _token = response.data.token;
      _userRole = response.data.role.toLowerCase();
      
      // Ambil info user dan simpan ke SharedPrefs
      try {
        final userResponse = await _authRepository.getUserInfo();
        _userInfo = userResponse.data;
        
        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(_userInfo!.toJson()));
      } catch (e) {
        // Abaikan error user info, tetap return sukses login
        print('Error getting user info: $e');
      }
      
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
    required String passwordConfirmation,
  }) async {
    return await _authRepository.register(
      username: username,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<void> logout() async {
    // Bersihkan SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
    
    // Hapus data dari secure storage
    await _storage.clearAll();
    
    // Reset state
    _token = null;
    _userRole = null;
    _userInfo = null;
    
    notifyListeners();
  }

  // Method untuk request reset password
  Future<bool> requestPasswordReset(String email) async {
    return await _authRepository.requestPasswordReset(email);
  }

  // Method untuk verifikasi OTP
  Future<bool> verifyOtp(String otp) async {
    return await _authRepository.verifyOtp(otp);
  }

  // Method untuk reset password
  Future<bool> resetPassword(String newPassword) async {
    return await _authRepository.resetPassword(newPassword);
  }

  // Method untuk get user info jika perlu refresh
  // Future<UserInfo?> refreshUserInfo() async {
  //   try {
  //     final response = await _authRepository.getUserInfo();
  //     _userInfo = response.data;
      
  //     // Simpan ke SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('user_info', json.encode(_userInfo!.toJson()));
      
  //     notifyListeners();
  //     return _userInfo;
  //   } catch (e) {
  //     return null;
  //   }
  // }
}