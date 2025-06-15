import 'package:flutter/material.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';
import '../widgets/filter_and_sort_widget.dart';

class StudentProvider with ChangeNotifier {
  final StudentRepository _studentRepository = StudentRepository();

  List<Student> _students = []; // Daftar master dari API
  List<Student> _filteredStudents = []; // Daftar yang akan dilihat oleh UI
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.az;

  // Getter yang digunakan oleh UI, selalu merujuk ke daftar yang sudah difilter
  List<Student> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch all students
  Future<void> fetchStudents() async {
    _isLoading = true;
    _error = null;
    // Panggilan pertama untuk menampilkan loading indicator di UI
    notifyListeners();

    try {
      // 1. Ambil data mentah dari repository
      _students = await _studentRepository.getStudents();

      // 2. Panggil method internal untuk mengisi _filteredStudents dari _students
      _applyFilterAndSort();
    } catch (e) {
      _error = e.toString();
      _students.clear();
      _filteredStudents.clear();
      print('Error fetching students: $e');
    } finally {
      _isLoading = false;
      // 3. Panggil notifyListeners() sekali di akhir setelah semua data siap
      notifyListeners();
    }
  }

  // Add new student
  Future<void> addStudent(Map<String, dynamic> newStudent) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate required fields
      if (newStudent['username'] == null ||
          newStudent['username'].toString().trim().isEmpty) {
        throw Exception('Username tidak boleh kosong');
      }
      if (newStudent['email'] == null ||
          newStudent['email'].toString().trim().isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }
      if (newStudent['password'] == null ||
          newStudent['password'].toString().trim().isEmpty) {
        throw Exception('Password tidak boleh kosong');
      }
      if (newStudent['nis'] == null ||
          newStudent['nis'].toString().trim().isEmpty) {
        throw Exception('NIS tidak boleh kosong');
      }
      if (newStudent['nama_lengkap'] == null ||
          newStudent['nama_lengkap'].toString().trim().isEmpty) {
        throw Exception('Nama lengkap tidak boleh kosong');
      }

      // Validate email format
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(newStudent['email'].toString())) {
        throw Exception('Format email tidak valid');
      }

      // Validate password length
      if (newStudent['password'].toString().length < 4) {
        throw Exception('Password minimal 4 karakter');
      }

      print('Adding student with data: $newStudent'); // Debug log

      await _studentRepository.createStudent(newStudent);

      // Refresh the student list after successful creation
      await fetchStudents();

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error adding student: $e');
      rethrow; // Re-throw to let the UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing student
  Future<bool> updateStudent(int id, Map<String, dynamic> studentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate required fields for update
      if (studentData['nama_lengkap'] == null ||
          studentData['nama_lengkap'].toString().trim().isEmpty) {
        throw Exception('Nama lengkap tidak boleh kosong');
      }
      if (studentData['email'] != null &&
          studentData['email'].toString().isNotEmpty) {
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(studentData['email'].toString())) {
          throw Exception('Format email tidak valid');
        }
      }

      await _studentRepository.updateStudent(id, studentData);
      await fetchStudents(); // Refresh list after update
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating student: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete student
  Future<void> deleteStudent(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _studentRepository.deleteStudent(id);

      // Remove from local list immediately for better UX
      _students.removeWhere((student) => student.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error deleting student: $e');
      // Refresh list to ensure consistency
      await fetchStudents();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get student by ID
  Student? getStudentById(int id) {
    try {
      return _students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search students by name or NIS
  List<Student> searchStudents(String query) {
    if (query.isEmpty) return _students;

    final lowercaseQuery = query.toLowerCase();
    return _students.where((student) {
      return student.namaLengkap.toLowerCase().contains(lowercaseQuery) ||
          student.nis.toLowerCase().contains(lowercaseQuery) ||
          student.username.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter students by class
  List<Student> getStudentsByClass(int classId) {
    return _students.where((student) => student.idKelas == classId).toList();
  }

  void _applyFilterAndSort() {
    List<Student> tempStudents = List.from(_students);

    // Filter berdasarkan nama lengkap
    if (_searchQuery.isNotEmpty) {
      tempStudents =
          tempStudents
              .where(
                (student) => student.namaLengkap.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    // Urutkan
    if (_sortOrder == SortOrder.az) {
      tempStudents.sort(
        (a, b) =>
            a.namaLengkap.toLowerCase().compareTo(b.namaLengkap.toLowerCase()),
      );
    } else {
      tempStudents.sort(
        (a, b) =>
            b.namaLengkap.toLowerCase().compareTo(a.namaLengkap.toLowerCase()),
      );
    }

    _filteredStudents = tempStudents;
  }

  /// Method publik yang dipanggil dari UI untuk menerapkan filter.
  void applyFilters(String query, SortOrder order) {
    _searchQuery = query;
    _sortOrder = order;
    _applyFilterAndSort();
    notifyListeners();
  }

  /// Method publik untuk mereset filter.
  void resetFilters() {
    _searchQuery = '';
    _sortOrder = SortOrder.az;
    _applyFilterAndSort();
    notifyListeners();
  }
}
