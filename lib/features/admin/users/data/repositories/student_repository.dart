import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentRepository {
  final StudentService _studentService = StudentService();

  /// Fetches all students from the API
  Future<List<Student>> getStudents() async {
    try {
      return await _studentService.getStudents();
    } catch (e) {
      // Log the error and rethrow
      print('Repository error in getStudents: $e');
      rethrow;
    }
  }

  /// Creates a new student
  Future<void> createStudent(Map<String, dynamic> newStudentData) async {
    try {
      // Validate data before sending to service
      if (newStudentData.isEmpty) {
        throw Exception('Data siswa tidak boleh kosong');
      }

      // Ensure required fields are present
      final requiredFields = [
        'username',
        'email', 
        'password',
        'nis',
        'nama_lengkap',
        'jenis_kelamin',
        'tanggal_lahir',
        'tempat_lahir',
        'alamat',
        'wali',
        'wa_wali',
        'id_kelas'
      ];

      for (String field in requiredFields) {
        if (!newStudentData.containsKey(field)) {
          newStudentData[field] = '';
        }
      }

      // Clean up data
      final cleanedData = <String, dynamic>{};
      newStudentData.forEach((key, value) {
        if (value != null) {
          cleanedData[key] = value.toString().trim();
        }
      });

      return await _studentService.createStudent(cleanedData);
    } catch (e) {
      print('Repository error in createStudent: $e');
      rethrow;
    }
  }

  /// Updates an existing student
  Future<void> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      if (id <= 0) {
        throw Exception('ID siswa tidak valid');
      }
      
      if (studentData.isEmpty) {
        throw Exception('Data update tidak boleh kosong');
      }

      // Clean up data
      final cleanedData = <String, dynamic>{};
      studentData.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          cleanedData[key] = value.toString().trim();
        }
      });

      return await _studentService.updateStudent(id, cleanedData);
    } catch (e) {
      print('Repository error in updateStudent: $e');
      rethrow;
    }
  }

  /// Deletes a student by ID
  Future<void> deleteStudent(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID siswa tidak valid');
      }
      
      return await _studentService.deleteStudent(id);
    } catch (e) {
      print('Repository error in deleteStudent: $e');
      rethrow;
    }
  }

  /// Get student by ID (if the API supports it)
  Future<Student?> getStudentById(int id) async {
    try {
      final students = await getStudents();
      return students.where((student) => student.id == id).firstOrNull;
    } catch (e) {
      print('Repository error in getStudentById: $e');
      return null;
    }
  }
}