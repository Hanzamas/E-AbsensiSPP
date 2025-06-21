import 'package:flutter/material.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  
  late final SecureStorage _storage;
  late final AuthRepository _repository;
  
  // ✅ Simple state variables
  String? _token;
  String? _role; // 'siswa', 'guru', 'admin'
  UserData? _user;
  bool _isLoading = false;
  String? _error; // ✅ ADD: Error state

  AuthProvider._internal() {
    _storage = SecureStorage();
    _repository = AuthRepository();
  }

  factory AuthProvider() => _instance;

  // ✅ Simple getters
  String? get token => _token;
  String? get role => _role;
  UserData? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _role != null;

  // ✅ Check existing auth with better error handling
  Future<String?> checkAuth() async {
    try {
      _token = await _storage.read('token');
      _role = await _storage.read('user_role');
      
      debugPrint('🔍 AuthProvider: Check auth - Token: ${_token != null}, Role: $_role');
      
      // ✅ Validate stored data
      if (_token != null && _role != null) {
        // Optional: Validate token with API
        notifyListeners();
        return _role;
      } else {
        // Clear invalid data
        await _clearAuth();
        return null;
      }
    } catch (e) {
      debugPrint('❌ AuthProvider: Check auth error - $e');
      await _clearAuth();
      return null;
    }
  }

  // ✅ Simple login with proper error handling
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🚀 AuthProvider: Starting login process');
      
      final response = await _repository.login(username, password);
      
      if (response.status) {
        // ✅ Normalize role to lowercase
        _token = response.token;
        _role = _normalizeRole(response.role);
        _user = response.user;

        // Save to secure storage
        await _storage.write('token', _token!);
        await _storage.write('user_role', _role!);

        debugPrint('✅ AuthProvider: Login successful - Role: $_role');
        
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        debugPrint('❌ AuthProvider: Login failed - ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e.toString());
      debugPrint('❌ AuthProvider: Login error - $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ ENHANCED: Logout with selective clearing (keeps session data)
  Future<void> logout([BuildContext? context]) async {
    _isLoading = true;
    notifyListeners();

    try {
      
      // ✅ Clear only auth data (keep session data for persistence)
      _token = null;
      _role = null;
      _user = null;
      _error = null;
      
      // ✅ Clear only auth-related storage keys (DON'T clear session data)
      await _storage.delete('token');
      await _storage.delete('user_role');
      await _storage.delete('user_data');
      // ✅ Keep: 'active_learning_session' for session persistence
      
      debugPrint('✅ AuthProvider: Logout successful - Session preserved');
    } catch (e) {
      debugPrint('❌ AuthProvider: Logout error - $e');
      // Force clear auth data
      _token = null;
      _role = null;
      _user = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Registration with error handling
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.register(
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      if (!success) {
        _error = 'Registrasi gagal';
      }
      
      return success;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Password reset methods with error handling
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.requestPasswordReset(email);
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.verifyOtp(otp);
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _repository.resetPassword(newPassword);
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Helper methods
  String getHomeRoute() {
    switch (_role) {
      case 'siswa':
        return '/student/home';
      case 'guru':
        return '/teacher/home';
      case 'admin':
        return '/admin/home';
      default:
        return '/login';
    }
  }

  // ✅ Clear all auth data
  Future<void> _clearAuth() async {
    _token = null;
    _role = null;
    _user = null;
    _error = null;
    
    await _storage.clearAll();
    notifyListeners();
  }

  // ✅ Normalize role from API response
  String _normalizeRole(String apiRole) {
    switch (apiRole.toLowerCase()) {
      case 'siswa':
      case 'student':
        return 'siswa';
      case 'guru':
      case 'teacher':
        return 'guru';
      case 'admin':
        return 'admin';
      default:
        return 'siswa'; // Default fallback
    }
  }

  // ✅ Parse error messages
  String _parseError(String error) {
    if (error.contains('Username atau password salah')) {
      return 'Username atau password salah';
    } else if (error.contains('401') || error.contains('unauthorized')) {
      return 'Username atau password salah';
    } else if (error.contains('not found') || error.contains('tidak ditemukan')) {
      return 'Akun tidak ditemukan';
    } else if (error.contains('validation') || error.contains('validasi')) {
      return 'Data tidak valid';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Koneksi internet bermasalah';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi nanti.';
    }
  }
}