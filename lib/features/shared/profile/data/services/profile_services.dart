import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class ProfileServices {
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
}