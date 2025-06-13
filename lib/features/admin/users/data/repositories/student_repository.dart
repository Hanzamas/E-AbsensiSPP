import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentRepository {
  final StudentService _studentService = StudentService();

  Future<List<Student>> getStudents() => _studentService.getStudents();

  Future<void> deleteStudent(int id) => _studentService.deleteStudent(id);
  
   Future<Student> createStudent(Map<String, dynamic> studentData) =>
      _studentService.createStudent(studentData);

  Future<void> updateStudent(int id, Map<String, dynamic> studentData) =>
      _studentService.updateStudent(id, studentData);
}