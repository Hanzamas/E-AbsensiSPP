import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../data/repositories/profile_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/student_profile_model.dart';
import '../data/models/teacher_profile_model.dart';
import '../data/models/class_model.dart';

class ProfileProvider extends ChangeNotifier {
  // Implementasi singleton factory
  static final ProfileProvider _instance = ProfileProvider._internal();
  
  // Factory constructor yang mengembalikan instance yang sama
  factory ProfileProvider() => _instance;
  
  // Deklarasi repository
  late final ProfileRepository _repository;
  
  // Private constructor
  ProfileProvider._internal() {
    _repository = ProfileRepository();
  }

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _localProfileImagePath;
  StudentProfile? studentProfile;
  TeacherProfile? teacherProfile;
  List<ClassModel> _classes = [];
  bool _isLoadingClasses = false;
  String? _errorClasses;

  static const String emptyProfilePictPath = '/uploads/';

  User? get userInfo => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get photoUrl => _user?.profilePict;
  String? get localProfileImagePath => _localProfileImagePath;
  List<ClassModel> get classes => _classes;
  bool get isLoadingClasses => _isLoadingClasses;
  String? get errorClasses => _errorClasses;

  // 3. Ambil Data Profil
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    _localProfileImagePath = prefs.getString('profile_image_path');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      // Jika file lokal tidak ada, download dari server
      if ((_localProfileImagePath == null || !File(_localProfileImagePath!).existsSync()) &&
          _user?.profilePict != null &&
          _user!.profilePict!.isNotEmpty &&
          _user!.profilePict != emptyProfilePictPath) {
        await downloadProfileImageFromServer(_user!.profilePict!);
      }
      _isLoading = false;
      notifyListeners();
      return;
    }
    // Jika cache tidak ada, fetch dari API
    await refresh();
  }
  

  // Fetch dari API dan simpan ke cache
  Future<void> refresh() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final user = await _repository.getUserInfo();
      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Upload Foto Profil
  Future<bool> uploadProfilePicture(File file) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // Upload ke server
      final fileUrl = await _repository.uploadProfilePicture(file);
      if (fileUrl.isEmpty) throw Exception('URL file kosong');
      // Update user info di server
      final user = await _repository.updateUserInfo(
        username: _user?.username ?? '',
        email: _user?.email ?? '',
        profilePict: fileUrl,
      );
      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // Copy file lokal hasil upload ke app dir
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = file.path.split('/').last;
        final localPath = '${appDir.path}/$fileName';
        final localFile = await file.copy(localPath);
        _localProfileImagePath = localFile.path;
        await prefs.setString('profile_image_path', localFile.path);
      }
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 2. Replace Foto Profil
  Future<bool> replaceProfilePicture(String oldFileName, File newFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // Replace file di server
      String fileUrl;
      try {
        fileUrl = await _repository.replaceProfilePicture(oldFileName, newFile);
      } catch (e) {
        // Jika file lama tidak ada (404), fallback ke upload baru
        if (e.toString().contains('404')) {
          fileUrl = await _repository.uploadProfilePicture(newFile);
        } else {
          rethrow;
        }
      }
      if (fileUrl.isEmpty) throw Exception('URL file kosong');
      // Update user info di server
      final user = await _repository.updateUserInfo(
        username: _user?.username ?? '',
        email: _user?.email ?? '',
        profilePict: fileUrl,
      );
      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // Copy file lokal hasil upload ke app dir
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = newFile.path.split('/').last;
        final localPath = '${appDir.path}/$fileName';
        final localFile = await newFile.copy(localPath);
        _localProfileImagePath = localFile.path;
        await prefs.setString('profile_image_path', localFile.path);
      }
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Hapus Foto Profil
  Future<bool> deleteProfilePicture(String fileName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // 1. Update user info dulu dengan profile_pict: emptyProfilePictPath
      final user = await _repository.updateUserInfo(
        username: _user?.username ?? '',
        email: _user?.email ?? '',
        profilePict: emptyProfilePictPath,
      );
      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // 2. Hapus file lokal jika ada
        if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
          await File(_localProfileImagePath!).delete();
          _localProfileImagePath = null;
          await prefs.remove('profile_image_path');
        }
        // 3. Coba hapus file di server (jika ada)
        if (fileName.isNotEmpty) {
          try {
            await _repository.deleteProfilePicture(fileName);
          } catch (e) {
            // Jika file sudah tidak ada (404) atau error lain, abaikan
          }
        }
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Gagal update user info');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Download gambar profil dari server (hanya jika file lokal tidak ada)
  Future<void> downloadProfileImageFromServer(String url) async {
    try {
      if (url.isEmpty || url == emptyProfilePictPath) return;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
      final savePath = '${appDir.path}/$fileName';
      final dio = DioClient().dio;
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final file = File(savePath);
      await file.writeAsBytes(response.data);
      _localProfileImagePath = savePath;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savePath);
      notifyListeners();
    } catch (e) {
      // Tidak perlu error handling khusus, cukup abaikan jika gagal
    }
  }

  // 4. Tampilkan Gambar Profil
  Widget getProfileImageWidget({double size = 100}) {
    if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(_localProfileImagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (photoUrl == null || photoUrl!.isEmpty || photoUrl == emptyProfilePictPath) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );
    }
    // Jika file lokal tidak ada, download dari server (sekali saja)
    downloadProfileImageFromServer(photoUrl!);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        shape: BoxShape.circle,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  // Clear cache dan state
  Future<void> clear() async {
    _user = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
    notifyListeners();
  }

  // Fetch profil dan kelas (untuk siswa) dalam 1 request
  Future<void> fetchProfileAndClasses(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    try {
      if (role == 'siswa') {
        // Cek cache untuk profil dan kelas
        final profileCache = prefs.getString('student_profile');
        final classesCache = prefs.getString('classes');
        
        if (profileCache != null && classesCache != null) {
          // Gunakan cache jika ada
          studentProfile = StudentProfile.fromJson(jsonDecode(profileCache));
          _classes = (jsonDecode(classesCache) as List)
              .map((json) => ClassModel.fromJson(json))
              .toList();
        } else {
          // Fetch dari API jika cache tidak ada
          final results = await Future.wait([
            _repository.getStudentProfile(),
            _repository.getClasses(),
          ]);
          // Cast results ke tipe yang benar
          final profileData = results[0] as Map<String, dynamic>;
          final classesData = results[1] as List<dynamic>;
          
          studentProfile = StudentProfile.fromJson(profileData);
          _classes = classesData.map((json) => ClassModel.fromJson(json as Map<String, dynamic>)).toList();
          
          // Simpan ke cache
          await prefs.setString('student_profile', jsonEncode(studentProfile!.toJson()));
          await prefs.setString('classes', jsonEncode(_classes.map((k) => k.toJson()).toList()));
        }
      } else {
        // Cek cache untuk profil guru
        final profileCache = prefs.getString('teacher_profile');
        if (profileCache != null) {
          teacherProfile = TeacherProfile.fromJson(jsonDecode(profileCache));
        } else {
          final data = await _repository.getTeacherProfile();
          teacherProfile = TeacherProfile.fromJson(data);
          await prefs.setString('teacher_profile', jsonEncode(teacherProfile!.toJson()));
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Update profil ke API dan update cache
  Future<bool> updateProfile(String role, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    try {
      if (role == 'siswa') {
        final updated = await _repository.updateStudentProfile(data);
        studentProfile = StudentProfile.fromJson(updated);
        prefs.setString('student_profile', jsonEncode(studentProfile!.toJson()));
      } else {
        final updated = await _repository.updateTeacherProfile(data);
        teacherProfile = TeacherProfile.fromJson(updated);
        prefs.setString('teacher_profile', jsonEncode(teacherProfile!.toJson()));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get nama kelas dari id
  String? getClassNameById(int? id) {
    if (id == null) return null;
    try {
      final kelas = _classes.firstWhere((k) => k.id == id);
      return kelas.displayName;
    } catch (e) {
      return null;
    }
  }

  // Get tahun ajaran dari id kelas
  String? getTahunAjaranByClassId(int? id) {
    if (id == null) return null;
    try {
      final kelas = _classes.firstWhere((k) => k.id == id);
      return kelas.tahunAjaran;
    } catch (e) {
      return null;
    }
  }

  // Get nama kelas dari id (tanpa tahun ajaran)
  String? getNamaKelasById(int? id) {
    if (id == null) return null;
    try {
      final kelas = _classes.firstWhere((k) => k.id == id);
      return kelas.namaKelas;
    } catch (e) {
      return null;
    }
  }

  // Clear cache saat logout
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_profile');
    await prefs.remove('teacher_profile');
    await prefs.remove('classes');
    await prefs.remove('profile_image_path');
    _classes = [];
    studentProfile = null;
    teacherProfile = null;
    notifyListeners();
  }

  // Update akun (username dan email)
  Future<bool> updateAccount({
    required String username,
    required String email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _repository.updateUserInfo(
        username: username,
        email: email,
        profilePict: _user?.profilePict,
      );

      if (user != null) {
        _user = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Gagal update user info');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}