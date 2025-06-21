import 'package:dio/dio.dart';
import '../models/teacher_model.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class TeacherService {
  final Dio _dio = DioClient().dio;

  // Mengambil semua data guru
  Future<List<Teacher>> getTeachers() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTeachersAdmin);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> teacherData = response.data['data'];
        return teacherData.map((json) => Teacher.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data guru: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<String> downloadTemplateExcel() async {
    // 1. Cek status izin penyimpanan saat ini
    var status = await [Permission.storage, Permission.manageExternalStorage].request();

    if (status[Permission.storage]!.isGranted || status[Permission.manageExternalStorage]!.isGranted) {
      Directory? dir;
      if (Platform.isAndroid) {
        // Deteksi versi Android dengan device_info_plus
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final int sdkInt = androidInfo.version.sdkInt;
        if (sdkInt <= 29) {
          // Android 10 ke bawah
          final String downloadPath = '/storage/emulated/0/Download';
          dir = Directory(downloadPath);
        } else {
          // Android 11 ke atas, tetap gunakan Download jika permission diberikan
          final String downloadPath = '/storage/emulated/0/Download';
          dir = Directory(downloadPath);
        }
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final savePath = '${dir.path}/template_guru.xlsx';

      try {
        final fullUrl = '${_dio.options.baseUrl}${ApiEndpoints.getFormatDownloadTeacher}';
        print('Mencoba mengunduh dari URL: $fullUrl');
        await _dio.download(ApiEndpoints.getFormatDownloadTeacher, savePath);
        return savePath;
      } on DioException catch (e) {
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception('Gagal mengunduh file: ${e.message}');
      } catch (e) {
        throw Exception('Gagal mengunduh file: $e');
      }
    } else if (status[Permission.storage]!.isPermanentlyDenied || status[Permission.manageExternalStorage]!.isPermanentlyDenied) {
      throw Exception(
        'Izin penyimpanan ditolak permanen. Harap aktifkan manual di Pengaturan Aplikasi.',
      );
    } else {
      throw Exception(
        'Izin penyimpanan ditolak. Fitur ini memerlukan akses ke penyimpanan.',
      );
    }
  }

  Future<String> importTeachersFromExcel(String filePath) async {
    try {
      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        ApiEndpoints.importTeacher,
        data: formData,
      );

      // Kondisi sukses: status code 200-299 dan status field true
      if ((response.statusCode! >= 200 && response.statusCode! < 300) &&
          response.data['status'] == true) {
        return response.data['message'];
      } else {
        throw Exception(
          'Gagal mengimpor data guru: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Gagal terhubung ke server.');
    }
  }

  // Membuat guru baru
  Future<void> createTeacher(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createTeacherAdmin,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception(response.data['message'] ?? 'Gagal menambahkan guru');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      print('Error in createTeacher: $e');
      throw Exception('Gagal terhubung ke server.');
    }
  }

  // Memperbarui data guru
  Future<void> updateTeacher(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateTeacherAdmin}/$id',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui guru');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      print('Error in updateTeacher: $e');
      throw Exception('Gagal terhubung ke server.');
    }
  }

  // Menghapus guru
  Future<void> deleteTeacher(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteTeacherAdmin}/$id',
      );
      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus guru');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
