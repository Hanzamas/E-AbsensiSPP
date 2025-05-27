import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../models/update_password_model.dart';

class ProfileServices {
  // Implementasi singleton factory
  static final ProfileServices _instance = ProfileServices._internal();
  
  // Factory constructor yang mengembalikan instance yang sama
  factory ProfileServices() => _instance;
  
  // Private constructor
  ProfileServices._internal();
  
  // Properties
  final Dio _dio = DioClient().dio;
  final String emptyProfilePictPath = '/uploads/';

  // 1. Get user info
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get(ApiEndpoints.usersMy);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data user');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // 2. Update user info (PUT)
  Future<Map<String, dynamic>> updateUserInfo({
    required String username,
    required String email,
    String? profilePict,
  }) async {
    try {
      final data = {
        'username': username,
        'email': email,
        'profile_pict': profilePict ?? emptyProfilePictPath,
      };
      final response = await _dio.put(
        ApiEndpoints.usersUpdate,
        data: data,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal update user info');
      }
    } catch (e) {
      throw Exception('Gagal update user info: $e');
    }
  }

  // 3. Upload foto profil baru
  Future<String> uploadProfilePicture(File file) async {
    try {
      // Cek ukuran file (max 1MB)
      final fileSize = await file.length();
      if (fileSize > 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar (maksimal 1MB)');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post(ApiEndpoints.filesUpload, data: formData);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data']['file_url'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal upload file');
      }
    } catch (e) {
      throw Exception('Gagal upload file: $e');
    }
  }

  // 4. Replace foto profil (update file lama)
  Future<String> replaceProfilePicture(String oldFileName, File newFile) async {
    try {
      // Cek ukuran file (max 1MB)
      final fileSize = await newFile.length();
      if (fileSize > 1024 * 1024) {
        throw Exception('Ukuran file terlalu besar (maksimal 1MB)');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(newFile.path),
      });
      final response = await _dio.put(
        '${ApiEndpoints.filesUpdate}/$oldFileName',
        data: formData,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data']['new_file_url'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal replace file');
      }
    } catch (e) {
      throw Exception('Gagal replace file: $e');
    }
  }

  // 5. Delete foto profil (hapus file di server)
  Future<bool> deleteProfilePicture(String fileName) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.filesDelete}/$fileName',
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal hapus file');
      }
    } catch (e) {
      throw Exception('Gagal hapus file: $e');
    }
  }

  // Siswa
  Future<Map<String, dynamic>> getStudentProfile() async {
    final response = await _dio.get(ApiEndpoints.getStudentProfile);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil data profil siswa');
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.updateStudent, data: data);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal update profil siswa');
    }
  }

  // Guru
  Future<Map<String, dynamic>> getTeacherProfile() async {
    final response = await _dio.get(ApiEndpoints.getTeacherProfile);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil data profil guru');
    }
  }

  Future<Map<String, dynamic>> updateTeacherProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.updateTeacher, data: data);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal update profil guru');
    }
  }

  // Kelas
  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await _dio.get(ApiEndpoints.getKelas);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil data kelas');
    }
  }

  Future<Map<String, dynamic>> getClassDetail(int id) async {
    final response = await _dio.get('${ApiEndpoints.getKelas}/detail/$id');
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil detail kelas');
    }
  }

  // Method untuk update password
  Future<Map<String, dynamic>> updatePassword(UpdatePasswordModel passwordData) async {
    try {
      // Validasi password terlebih dahulu
      if (!passwordData.validate()) {
        throw Exception('Validasi password gagal');
      }

      final response = await _dio.put(
        ApiEndpoints.usersUpdatePassword,
        data: passwordData.toJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal update password');
      }
    } catch (e) {
      throw Exception('Gagal update password: $e');
    }
  }
}