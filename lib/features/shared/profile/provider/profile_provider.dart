import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../data/repositories/profile_repository.dart';
import '../data/models/basic_user_info.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  BasicUserInfo? _userInfo;
  bool _isLoading = false;
  String? _error;
  String? _localProfileImagePath;

  BasicUserInfo? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get photoUrl => _userInfo?.profilePict;
  String? get localProfileImagePath => _localProfileImagePath;

  // 3. Ambil Data Profil
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    _localProfileImagePath = prefs.getString('profile_image_path');
    if (userJson != null) {
      _userInfo = BasicUserInfo.fromJson(json.decode(userJson));
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
        _userInfo = user;
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
        username: _userInfo?.username ?? '',
        email: _userInfo?.email ?? '',
        profilePict: fileUrl,
      );
      if (user != null) {
        _userInfo = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // Hapus file lokal lama jika ada
        if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
          await File(_localProfileImagePath!).delete();
        }
        // Download ulang file dari server (timestamp)
        await downloadProfileImageFromServer(user.profilePict ?? fileUrl);
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
        username: _userInfo?.username ?? '',
        email: _userInfo?.email ?? '',
        profilePict: fileUrl,
      );
      if (user != null) {
        _userInfo = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // Hapus file lokal lama jika ada
        if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
          await File(_localProfileImagePath!).delete();
        }
        // Download ulang file dari server (timestamp)
        await downloadProfileImageFromServer(user.profilePict ?? fileUrl);
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
      // Hapus file di server
      final success = await _repository.deleteProfilePicture(fileName);
      if (!success) throw Exception('Gagal menghapus file');
      // Update user info di server dengan profile_pict: ''
      final user = await _repository.updateUserInfo(
        username: _userInfo?.username ?? '',
        email: _userInfo?.email ?? '',
        profilePict: '', // string kosong!
      );
      if (user != null) {
        _userInfo = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', json.encode(user.toJson()));
        // Hapus file lokal jika ada
        if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
          await File(_localProfileImagePath!).delete();
          _localProfileImagePath = null;
          await prefs.remove('profile_image_path');
        }
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

  // Download gambar profil dari server (timestamp)
  Future<void> downloadProfileImageFromServer(String url) async {
    try {
      if (url.isEmpty) return;
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
      _error = 'Gagal download gambar profil: $e';
      notifyListeners();
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
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Jika file lokal tidak ada, download manual dari server
      downloadProfileImageFromServer(photoUrl!);
      // Sementara tampilkan placeholder/loading
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          shape: BoxShape.circle,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
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
  }

  // Clear cache dan state
  Future<void> clear() async {
    _userInfo = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
    notifyListeners();
  }
}