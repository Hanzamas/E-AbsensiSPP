import 'package:dio/dio.dart';
import '../models/student_model.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class StudentService {
  // final Dio _dio = Dio();
  final Dio _dio = DioClient().dio;

  // Fetches all students from the API
  Future<List<Student>> getStudents() async {
    try {
      // Assuming the endpoint is '/admin/students'
      final response = await _dio.get(ApiEndpoints.getStudents);

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> studentData = response.data['data'];
        return studentData.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students: ${response.data['message']}');
      }
    } catch (e) {
      // Handle Dio errors or other exceptions
      print(e);
      throw Exception('Failed to connect to the server.');
    }
  }

    Future<Student> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createStudentadmin,
        data: studentData,
      );

      // API bisa merespons dengan status 200 (OK) atau 201 (Created)
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['status'] == true) {
        return Student.fromJson(response.data['data']);
      } else {
        // Jika status dari API adalah false
        throw Exception(
            response.data['message'] ?? 'Gagal membuat siswa.');
      }
    } on DioError catch (e) {
      // Menangkap error spesifik dari Dio (misal: 404, 422, 500)
      // Pesan error dari server biasanya ada di e.response.data
      String errorMessage = "Terjadi kesalahan pada server.";
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      // Lemparkan exception dengan pesan yang lebih jelas
      throw Exception(errorMessage);
    } catch (e) {
      // Menangkap error lainnya
      throw Exception("Gagal terhubung atau terjadi kesalahan lain: $e");
    }
  }

  Future<void> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateStudentadmin}/$id', // Asumsi endpoint PUT
        data: studentData,
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui siswa: ${response.data?['message']}',
        );
      }
    } catch (e) {
      throw Exception('Gagal memperbarui siswa $e.');
    }
  }

  // Deletes a student by their ID
  Future<void> deleteStudent(int id) async {
    try {
      // NOTE: Assumes a standard REST API endpoint like '/admin/students/{id}'
      final response = await _dio.delete('${ApiEndpoints.deleteStudent}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete student.');
      }
    } catch (e) {
      throw Exception('Failed to delete student $e.');
    }
  }

  // NOTE: The update logic would go here, likely sending a PUT or POST request.
  // The implementation depends on your API's update endpoint.
}
