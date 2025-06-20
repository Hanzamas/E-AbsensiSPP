import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../models/academic_year_model.dart';

class AcademicYearService {
  final Dio _dio = DioClient().dio;

  Future<List<AcademicYearModel>> getAllAcademicYears() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAcademicYears,
      ); // Tambahkan endpoint ini
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AcademicYearModel.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data tahun ajaran',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    }
  }

  Future<AcademicYearModel> createAcademicYear(
    AcademicYearModel academicYear,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createAcademicYear,
        data: academicYear.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['status'] == true) {
        final newId = response.data['data']['id'];
        return AcademicYearModel(
          id: newId,
          nama: academicYear.nama,
          tanggalMulai: academicYear.tanggalMulai,
          tanggalSelesai: academicYear.tanggalSelesai,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Gagal membuat tahun ajaran',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Terjadi kesalahan saat membuat tahun ajaran',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk update tahun ajaran (BARU)
  Future<void> updateAcademicYear(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateAcademicYear}/$id', // Tambahkan endpoint ini
        data: data,
      );
      if (response.statusCode != 200 || response.data['status'] != true) {
        throw Exception(
          response.data['message'] ?? 'Gagal mengupdate tahun ajaran',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    }
  }

  // Method untuk hapus tahun ajaran (BARU)
  Future<void> deleteAcademicYear(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteAcademicYear}/$id',
      ); // Tambahkan endpoint ini
      if (response.statusCode != 200 || response.data['status'] != true) {
        throw Exception(
          response.data['message'] ?? 'Gagal menghapus tahun ajaran',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    }
  }
}

// Catatan: Pastikan Anda menambahkan endpoint di file `api_endpoints.dart`
// static const String createAcademicYear = '/admin/academic-year/create';
