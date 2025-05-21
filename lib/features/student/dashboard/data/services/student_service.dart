import 'package:dio/dio.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  late final Dio _dio;
  late final SecureStorage _storage;

  // Private constructor
  StudentService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _storage = SecureStorage();
  }

  // Singleton factory
  factory StudentService() => _instance;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token not found');

      final response = await _dio.get(
        ApiEndpoints.getProfile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Internal Server Error');
      }
      throw Exception('Failed to get profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
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
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token not found');

      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'id_kelas': idKelas,
          'nis': nis,
          'nama_lengkap': namaLengkap,
          'jenis_kelamin': jenisKelamin,
          'tanggal_lahir': tanggalLahir,
          'tempat_lahir': tempatLahir,
          'alamat': alamat,
          'wali': wali,
          'wa_wali': waWali,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Bad request');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Internal Server Error');
      }
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentSchedule() async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token not found');

      final response = await _dio.get(
        ApiEndpoints.getStudentSchedule,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get schedule');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get schedule: $e');
    }
  }
}