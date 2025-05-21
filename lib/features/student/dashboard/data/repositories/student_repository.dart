import '../services/student_service.dart';
import '../models/student.dart';
import '../models/schedule.dart';

class StudentRepository {
  static final StudentRepository _instance = StudentRepository._internal();
  late final StudentService _service;
  
  // Private constructor
  StudentRepository._internal() {
    _service = StudentService();
  }

  // Singleton factory
  factory StudentRepository() => _instance;

  Future<Student> getProfile() async {
    try {
      final response = await _service.getProfile();
      if (response['status'] == true) {
        return Student.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to get profile');
      }
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
      final response = await _service.updateProfile(
        idKelas: idKelas,
        nis: nis,
        namaLengkap: namaLengkap,
        jenisKelamin: jenisKelamin,
        tanggalLahir: tanggalLahir,
        tempatLahir: tempatLahir,
        alamat: alamat,
        wali: wali,
        waWali: waWali,
      );
      
      if (response['status'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<List<Schedule>> getSchedule() async {
    try {
      final response = await _service.getStudentSchedule();
      if (response['status'] == true) {
        final List<dynamic> list = response['data'] ?? [];
        return list.map((e) => Schedule.fromJson(e)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to get schedule');
      }
    } catch (e) {
      throw Exception('Failed to get schedule: $e');
    }
  }
}