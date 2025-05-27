import '../models/user_model.dart';
import '../services/profile_services.dart';
import '../models/update_password_model.dart';
import 'dart:io';

class ProfileRepository {
  // Implementasi singleton factory
  static final ProfileRepository _instance = ProfileRepository._internal();
  
  // Factory constructor yang mengembalikan instance yang sama
  factory ProfileRepository() => _instance;
  
  // Deklarasi service
  late final ProfileServices _service;
  
  // Private constructor
  ProfileRepository._internal() {
    _service = ProfileServices();
  }

  Future<User?> getUserInfo() async {
    final data = await _service.getUserInfo();
    return User.fromJson(data);
  }

  Future<User?> updateUserInfo({
    required String username,
    required String email,
    String? profilePict,
  }) async {
    final data = await _service.updateUserInfo(
      username: username,
      email: email,
      profilePict: profilePict,
    );
    return User.fromJson(data);
  }

  Future<String> uploadProfilePicture(File file) async {
    return await _service.uploadProfilePicture(file);
  }

  Future<String> replaceProfilePicture(String oldFileName, File newFile) async {
    return await _service.replaceProfilePicture(oldFileName, newFile);
  }

  Future<bool> deleteProfilePicture(String fileName) async {
    return await _service.deleteProfilePicture(fileName);
  }

  // Method untuk update password
  Future<User?> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final passwordData = UpdatePasswordModel(
      oldPassword: oldPassword, 
      newPassword: newPassword
    );
    
    final data = await _service.updatePassword(passwordData);
    return User.fromJson(data);
  }

  // Siswa
  Future<Map<String, dynamic>> getStudentProfile() => _service.getStudentProfile();
  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> data) => _service.updateStudentProfile(data);

  // Guru
  Future<Map<String, dynamic>> getTeacherProfile() => _service.getTeacherProfile();
  Future<Map<String, dynamic>> updateTeacherProfile(Map<String, dynamic> data) => _service.updateTeacherProfile(data);

  // Kelas
  Future<List<Map<String, dynamic>>> getClasses() => _service.getClasses();
  Future<Map<String, dynamic>> getClassDetail(int id) => _service.getClassDetail(id);
}