import 'package:dio/dio.dart';
import '../models/student_model.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class StudentService {
  final Dio _dio = DioClient().dio;

  // Fetches all students from the API
  Future<List<Student>> getStudents() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudents);

      print('Raw API Response: ${response.data}'); // Debug log

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> studentData = response.data['data'];
        
        // Debug log untuk melihat struktur data
        print('Student data count: ${studentData.length}');
        if (studentData.isNotEmpty) {
          print('First student data: ${studentData.first}');
        }
        
        final List<Student> students = studentData.map((json) {
          try {
            final student = Student.fromJson(json);
            print('Parsed student: ${student.namaLengkap}, Email: ${student.email}'); // Debug log
            return student;
          } catch (e) {
            print('Error parsing student data: $json, Error: $e');
            rethrow;
          }
        }).toList();
        
        return students;
      } else {
        throw Exception('Failed to load students: ${response.data['message']}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      if (e.response != null) {
        print('Dio error response: ${e.response!.data}'); // Debug log
        throw Exception('Server error: ${e.response!.data['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Error in getStudents: $e');
      throw Exception('Failed to connect to the server.');
    }
  }

  // Creates a new student
  Future<void> createStudent(Map<String, dynamic> data) async {
    try {
      print('Sending student data: $data'); // Debug log
      
      final response = await _dio.post(
        ApiEndpoints.createStudentadmin,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response data: ${response.data}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          // Success
          return;
        } else {
          throw Exception(
            response.data['message'] ?? 'Gagal menambahkan siswa',
          );
        }
      } else {
        throw Exception(
          'HTTP Error ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      print('DioException in createStudent: ${e.toString()}'); // Debug log
      
      if (e.response != null) {
        final errorMessage = e.response!.data is Map
            ? e.response!.data['message'] ?? 'Server error'
            : 'Server error';
        throw Exception('Gagal menambahkan siswa: $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server tidak merespons. Coba lagi nanti.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('General error in createStudent: $e'); // Debug log
      throw Exception('Error saat menambahkan siswa: $e');
    }
  }

  // Updates an existing student
  Future<void> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateStudentadmin}/$id',
        data: studentData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return;
        } else {
          throw Exception(
            response.data['message'] ?? 'Gagal memperbarui siswa',
          );
        }
      } else {
        throw Exception(
          'HTTP Error ${response.statusCode}: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response!.data is Map
            ? e.response!.data['message'] ?? 'Server error'
            : 'Server error';
        throw Exception('Gagal memperbarui siswa: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error saat memperbarui siswa: $e');
    }
  }

  // Deletes a student by their ID
  Future<void> deleteStudent(int id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.deleteStudent}/$id');
      
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return;
        } else {
          throw Exception(
            response.data['message'] ?? 'Gagal menghapus siswa',
          );
        }
      } else {
        throw Exception(
          'HTTP Error ${response.statusCode}: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response!.data is Map
            ? e.response!.data['message'] ?? 'Server error'
            : 'Server error';
        throw Exception('Gagal menghapus siswa: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error saat menghapus siswa: $e');
    }
  }
}