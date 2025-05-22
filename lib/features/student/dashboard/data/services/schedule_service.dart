import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import 'package:e_absensi/features/student/dashboard/data/models/schedule_model.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  late final Dio _dio;


  // Private constructor
  ScheduleService._internal() {
    _dio = DioClient().dio;
    
  }

  // Singleton factory
  factory ScheduleService() => _instance;

  Future<List<Schedule>> getStudentSchedule() async {
    try {
      // print('Mengambil jadwal dari: ${ApiEndpoints.getStudentSchedule}');
      final response = await _dio.get(ApiEndpoints.getStudentSchedule);
      // print('Response status code: ${response.statusCode}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        // print('Data jadwal: $data');
        return data.map((json) => Schedule.fromJson(json)).toList();
      }
      throw 'Gagal mengambil jadwal';
    } on DioException catch (e) {
      // print('Error mengambil jadwal: ${e.message}');
      // print('Error response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw 'Sesi anda telah berakhir. Silakan login kembali.';
      }
      throw 'Gagal mengambil jadwal';
    }
  }
} 