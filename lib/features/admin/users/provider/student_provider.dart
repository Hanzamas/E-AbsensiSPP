import 'package:flutter/material.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';

class StudentProvider with ChangeNotifier {
  final StudentRepository _studentRepository = StudentRepository();

  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _studentRepository.getStudents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  

  Future<bool> updateStudent(int id, Map<String, dynamic> studentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _studentRepository.updateStudent(id, studentData);
      await fetchStudents(); // Muat ulang daftar setelah berhasil
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _studentRepository.deleteStudent(id);
      _students.removeWhere((student) => student.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
