// import 'package:dio/dio.dart';
// import 'package:e_absensi/core/storage/secure_storage.dart';
// import 'package:e_absensi/core/api/api_endpoints.dart';
// import 'package:e_absensi/core/api/dio_client.dart';

// class AttendanceService {
//   static final AttendanceService _instance = AttendanceService._internal();
//   late final Dio _dio;
//   late final SecureStorage _storage;

//   // Private constructor
//   AttendanceService._internal() {
//     _dio = DioClient().dio;
//     _storage = SecureStorage();
//   }

//   // Singleton factory
//   factory AttendanceService() => _instance;

//   Future<Map<String, dynamic>> getAttendanceHistory() async {
//     try {
//       final token = await _storage.read('token');
//       if (token == null) throw Exception('Token tidak ditemukan');

//       final response = await _dio.get(
//         ApiEndpoints.getAttendanceDetail,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception(response.data['message'] ?? 'Gagal memuat data absensi');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         throw Exception(e.response?.data['message'] ?? 'Bad request');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Data absensi tidak ditemukan');
//       } else if (e.response?.statusCode == 500) {
//         throw Exception('Internal Server Error');
//       }
//       throw Exception('Gagal memuat data absensi: ${e.message}');
//     } catch (e) {
//       throw Exception('Gagal memuat data absensi: $e');
//     }
//   }

//   Future<Map<String, dynamic>> submitAttendance(String qrCode) async {
//     try {
//       final token = await _storage.read('token');
//       if (token == null) throw Exception('Token tidak ditemukan');

//       final response = await _dio.post(
//         ApiEndpoints.getAttendanceDetail + '/submit',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         ),
//         data: {
//           'qr_code': qrCode
//         }
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception(response.data['message'] ?? 'Gagal submit absensi');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         throw Exception(e.response?.data['message'] ?? 'QR Code tidak valid');
//       } else if (e.response?.statusCode == 404) {
//         throw Exception('Data absensi tidak ditemukan');
//       } else if (e.response?.statusCode == 500) {
//         throw Exception('Internal Server Error');
//       }
//       throw Exception('Gagal submit absensi: ${e.message}');
//     } catch (e) {
//       throw Exception('Gagal submit absensi: $e');
//     }
//   }
// } 