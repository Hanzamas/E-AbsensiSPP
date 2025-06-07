import 'package:dio/dio.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

class StudentAttendanceService {
  static final StudentAttendanceService _instance = StudentAttendanceService._internal();
  late final Dio _dio;
  late final SecureStorage _storage;

  // Private constructor
  StudentAttendanceService._internal() {
    _dio = DioClient().dio;
    _storage = SecureStorage();
  }

  // Singleton factory
  factory StudentAttendanceService() => _instance;

  // Get attendance history with filters
  Future<Map<String, dynamic>> getAttendanceHistory({
    String? mapel,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      Map<String, dynamic> queryParams = {};
      if (mapel != null && mapel.isNotEmpty) queryParams['mapel'] = mapel;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        ApiEndpoints.getStudentAttendance,
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data absensi');
      }
    } catch (e) {
      throw Exception('Gagal mengambil riwayat absensi: $e');
    }
  }

  // Get student schedule
  Future<Map<String, dynamic>> getStudentSchedule() async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.get(
        ApiEndpoints.getStudentSchedule,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil jadwal');
      }
    } catch (e) {
      throw Exception('Gagal mengambil jadwal: $e');
    }
  }

  // Scan QR Code
  Future<Map<String, dynamic>> scanQRCode(String qrToken) async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await _dio.post(
        ApiEndpoints.scanStudentAttendance,
        data: {'qr_token': qrToken},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal scan QR code');
      }
    } catch (e) {
      throw Exception('Gagal scan QR code: $e');
    }
  }

  // ✅ FIXED: Use correct endpoint from api_endpoints.dart
  Future<String> downloadAttendanceExcel() async {
    try {
      final token = await _storage.read('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      print('🔍 Debug: Downloading from ${ApiEndpoints.getStudentDownloadAttendance}');
      print('🔍 Debug: Token exists: ${token.isNotEmpty}');

      // ✅ Use endpoint from api_endpoints.dart
      final response = await _dio.get(
        ApiEndpoints.getStudentDownloadAttendance, // ✅ Correct endpoint
        options: Options(
          headers: {
            
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // ✅ Excel MIME type
          },
          responseType: ResponseType.bytes,
          followRedirects: true, // ✅ Follow redirects if any
          validateStatus: (status) {
            return status != null && status < 500; // ✅ Accept all status < 500
          },
        ),
      );

      print('🔍 Debug: Response status: ${response.statusCode}');
      print('🔍 Debug: Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // ✅ Check if response contains data
        if (response.data == null || (response.data as Uint8List).isEmpty) {
          throw Exception('File download kosong dari server');
        }

        // ✅ Get app documents directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        
        // ✅ Create filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'riwayat_absensi_$timestamp.xlsx';
        final filePath = '${appDir.path}/$fileName';

        print('🔍 Debug: Saving to: $filePath');

        // ✅ Write file to app directory
        final file = File(filePath);
        await file.writeAsBytes(response.data as Uint8List);

        // ✅ Verify file was created
        if (await file.exists()) {
          final fileSize = await file.length();
          print('🔍 Debug: File created successfully, size: $fileSize bytes');
          return filePath;
        } else {
          throw Exception('Gagal menyimpan file ke storage');
        }

      } else if (response.statusCode == 403) {
        // ✅ Handle 403 specifically
        print('🔍 Debug: 403 response data: ${response.data}');
        throw Exception('Akses ditolak - periksa permission atau login ulang');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint download tidak ditemukan');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🔍 Debug: DioException: ${e.type}');
      print('🔍 Debug: DioException message: ${e.message}');
      print('🔍 Debug: DioException response: ${e.response?.data}');
      
      if (e.response?.statusCode == 403) {
        throw Exception('Akses ditolak - silakan login ulang');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint download tidak ditemukan');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid - silakan login ulang');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error saat generate file');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout - periksa internet');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Download timeout - file terlalu besar');
      } else {
        throw Exception('Gagal download: ${e.message}');
      }
    } catch (e) {
      print('🔍 Debug: General error: $e');
      throw Exception('Gagal download excel: $e');
    }
  }




  Future<Map<String, dynamic>> submitAttendance(String qrCode) async {
    try {
      final token = await _storage.read('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await _dio.post(
      ApiEndpoints.scanStudentAttendance, // ✅ Use correct endpoint
      options: Options(headers: { 'Authorization': 'Bearer $token' }),
      data: { 'qr_code': qrCode }
    );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal submit absensi');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'QR Code tidak valid');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Data absensi tidak ditemukan');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Internal Server Error');
      }
      throw Exception('Gagal submit absensi: ${e.message}');
    } catch (e) {
      throw Exception('Gagal submit absensi: $e');
    }
  }
} 