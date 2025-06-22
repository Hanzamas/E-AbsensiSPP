import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/attendance_record_model.dart';
import '../models/spp_record_model.dart';
import '../../../../../core/api/api_endpoints.dart';

class ReportService {
  final Dio _dio = DioClient().dio;

  Future<String> downloadReport({
    required String endpoint,
    required String saveFileName,
    Map<String, dynamic>? queryParams,
  }) async {
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

      final savePath = '${dir.path}/$saveFileName';

      try {
        final validQueryParams = <String, dynamic>{};
        if (queryParams != null) {
          queryParams.forEach((key, value) {
            if (value != null && value.toString().isNotEmpty) {
              validQueryParams[key] = value;
            }
          });
        }
        
        await _dio.download(
          endpoint,
          savePath,
          queryParameters: validQueryParams,
        );
        return savePath;
      } on DioException catch (e) {
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception('Gagal mengunduh file: ${e.response?.data?['message'] ?? e.message}');
      } catch (e) {
        throw Exception('Terjadi kesalahan: $e');
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
    Future<List<AttendanceRecord>> getAllAttendanceRecords() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllAttendanceReports);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data absensi');
    } on DioException catch (e) {
      throw Exception('Error Absensi: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<List<SppRecord>> getAllSppRecords() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllSppReports);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SppRecord.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data SPP');
    } on DioException catch (e) {
      throw Exception('Error SPP: ${e.response?.data?['message'] ?? e.message}');
    }
  }
}