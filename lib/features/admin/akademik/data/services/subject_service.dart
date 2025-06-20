import 'package:dio/dio.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../../../../core/api/dio_client.dart';
import '../models/subject_model.dart';

class SubjectService {
  final Dio _dio = DioClient().dio;

  /// Mengambil semua data mata pelajaran dari API
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await _dio.get(ApiEndpoints.getSubjects);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> subjectsData = response.data['data'] ?? [];
        return subjectsData.map((data) => SubjectModel.fromJson(data)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data mata pelajaran');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Terjadi kesalahan saat mengambil data mata pelajaran',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mengirim data mata pelajaran baru ke API
  Future<void> createSubject(SubjectModel subject) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createSubject,
        data: subject.toCreateJson(),
      );

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal membuat mata pelajaran');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Terjadi kesalahan saat membuat mata pelajaran',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mengirim data pembaruan mata pelajaran ke API
  Future<SubjectModel> updateSubject(int id, SubjectModel subject) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateSubject}/$id',
        data: subject.toUpdateJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('Data mata pelajaran tidak ditemukan dalam respons');
        }
        return SubjectModel.fromJson(data);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengupdate mata pelajaran');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Terjadi kesalahan saat mengupdate mata pelajaran',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Menghapus data mata pelajaran dari API berdasarkan ID
  Future<bool> deleteSubject(int id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.deleteSubject}/$id');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      }
      throw Exception(response.data['message'] ?? 'Gagal menghapus mata pelajaran');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Terjadi kesalahan saat menghapus mata pelajaran',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
