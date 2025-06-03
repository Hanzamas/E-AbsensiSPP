import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../models/class_model.dart';

class ClassRepository {
  final Dio _dio = DioClient().dio;

  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await _dio.get(ApiEndpoints.getClasses);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> classesData = response.data['data'] ?? [];
        return classesData.map((data) => ClassModel.fromJson(data)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data kelas');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat mengambil data kelas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ClassModel> createClass(ClassModel classData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createClass,
        data: classData.toCreateJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Data kelas tidak ditemukan dalam respons');
        }
        return ClassModel.fromJson(data);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat kelas');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat membuat kelas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

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
        return ClassModel.fromJson(data);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengupdate kelas');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat mengupdate kelas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.deleteClass}/$id');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      }
      throw Exception(response.data['message'] ?? 'Gagal menghapus kelas');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat menghapus kelas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 