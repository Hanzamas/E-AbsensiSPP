import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';

class ProfileProvider extends ChangeNotifier {
  static final ProfileProvider _instance = ProfileProvider._internal();
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _studentData;
  List<Map<String, dynamic>> _kelasList = [];
  
  // Private constructor
  ProfileProvider._internal();
  
  // Singleton factory
  factory ProfileProvider() => _instance;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profileData => _profileData;
  Map<String, dynamic>? get studentData => _studentData;
  List<Map<String, dynamic>> get kelasList => _kelasList;
  
  String? get nama => _studentData?['nama_lengkap'] ?? _profileData?['siswa_nama_lengkap'] ?? _profileData?['nama'];
  String? get email => _profileData?['email'];
  bool get isProfileCompleted => _profileData?['siswa_nama_lengkap'] != null;
  String? get profilePictureUrl => _profileData?['foto_url'];
  
  // Load profile data
  Future<void> loadProfile() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());
    
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _error = 'Token tidak ditemukan';
        return;
      }
      
      // Fetch profile data
      final profileResponse = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final profileData = jsonDecode(profileResponse.body);
      if (profileResponse.statusCode != 200 || profileData['status'] != true) {
        _error = profileData['message'] ?? 'Gagal memuat data profil';
        return;
      }
      
      _profileData = profileData['data'];
      
      // If profile is completed, get student data
      if (isProfileCompleted) {
        await loadStudentData(token);
      }
      
      // Load kelas list
      await loadKelasList(token);
      
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Load student data
  Future<void> loadStudentData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getStudentDetail}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true && data['data'] != null) {
        _studentData = data['data'];
      } else {
        _error = data['message'] ?? 'Gagal memuat data siswa';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    }
  }
  
  // Load kelas list
  Future<void> loadKelasList(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getKelas),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        final List kelas = data['data'];
        _kelasList = kelas.map<Map<String, dynamic>>((k) => {
          'id': k['id'],
          'nama': k['nama'],
        }).toList();
      }
    } catch (e) {
      print('Error loading kelas list: ${e.toString()}');
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    required int idKelas,
    required String nis,
    required String namaLengkap,
    required String jenisKelamin,
    required String tanggalLahir,
    required String tempatLahir,
    required String alamat,
    required String wali,
    required String waWali,
  }) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());
    
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _error = 'Token tidak ditemukan';
        return false;
      }
      
      String formattedDate = tanggalLahir;
      if (formattedDate.contains('T')) {
        formattedDate = formattedDate.split('T')[0];
      }
      
      final updatePayload = {
        'id_kelas': idKelas,
        'nis': nis,
        'nama_lengkap': namaLengkap,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': formattedDate,
        'tempat_lahir': tempatLahir,
        'alamat': alamat,
        'wali': wali,
        'wa_wali': waWali,
      };
      
      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatePayload),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        // Refresh profile data
        await loadProfile();
        return true;
      } else {
        _error = data['message'] ?? 'Gagal mengupdate profil';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _profileData = null;
    _studentData = null;
    _kelasList = [];
    Future.microtask(() => notifyListeners());
  }
  
  // Upload profile picture
  Future<bool> uploadProfilePicture(String imagePath) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());
    
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _error = 'Token tidak ditemukan';
        return false;
      }
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.uploadProfilePicture)
      );
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('foto', imagePath),
      );
      
      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      
      if (response.statusCode == 200 && data['status'] == true) {
        // Refresh profile data
        await loadProfile();
        return true;
      } else {
        _error = data['message'] ?? 'Gagal mengupload foto profil';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Update account
  Future<bool> updateAccount({
    required String username,
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());
    
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _error = 'Token tidak ditemukan';
        return false;
      }
      
      final updatePayload = {
        'username': username,
        'email': email,
      };
      
      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.updateUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatePayload),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        // Refresh profile data
        await loadProfile();
        return true;
      } else {
        _error = data['message'] ?? 'Gagal mengupdate akun';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Update password
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());
    
    try {
      if (newPassword != confirmPassword) {
        _error = 'Konfirmasi password tidak sesuai';
        return false;
      }
      
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        _error = 'Token tidak ditemukan';
        return false;
      }
      
      final updatePayload = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
      
      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.updatePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatePayload),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return true;
      } else {
        _error = data['message'] ?? 'Gagal mengupdate password';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
} 