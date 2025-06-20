import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../models/class_model.dart';

class ClassService {
  final Dio _dio = DioClient().dio;

  /// Mengambil semua data kelas dari API
  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await _dio.get(ApiEndpoints.getClasses);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> classesData = response.data['data'] ?? [];
        return classesData.map((data) => ClassModel.fromJson(data)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data kelas');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Terjadi kesalahan saat mengambil data kelas',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mengirim data kelas baru ke API
  Future<void> createClass(ClassModel classData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createClass,
        data: classData.toCreateJson(),
      );

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal membuat kelas');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Terjadi kesalahan saat membuat kelas',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mengirim data pembaruan kelas ke API
  Future<ClassModel> updateClass(int id, ClassModel classData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateClass}/$id',
        data: classData.toUpdateJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Data kelas tidak ditemukan dalam respons');
        }

        // 🔍 Tambahkan logging untuk debug
        print('Response data: $data');
        print('Data types: ${data.map((k, v) => MapEntry(k, v.runtimeType))}');

        return ClassModel.fromJson(data);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengupdate kelas');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Terjadi kesalahan saat mengupdate kelas',
      );
    } catch (e) {
      print('Parse error: $e'); // 🔍 Log error parsing
      throw Exception('Error: $e');
    }
  }

  /// Menghapus data kelas dari API berdasarkan ID
  Future<bool> deleteClass(int id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.deleteClass}/$id');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      }
      throw Exception(response.data['message'] ?? 'Gagal menghapus kelas');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Terjadi kesalahan saat menghapus kelas',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
