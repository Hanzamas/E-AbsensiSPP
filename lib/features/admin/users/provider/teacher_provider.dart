import 'package:flutter/material.dart';
import '../data/models/teacher_model.dart';
import '../data/repositories/teacher_repository.dart';
import '../widgets/filter_and_sort_widget.dart';
class TeacherProvider with ChangeNotifier {
  final TeacherRepository _teacherRepository = TeacherRepository();

  List<Teacher> _teachers = [];
  List<Teacher> _filteredTeachers = [];
  bool _isLoading = false;
  String? _error;

  List<Teacher> get teachers => _filteredTeachers; 
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.az;

   Future<void> fetchTeachers() async {
    _isLoading = true;
    _error = null;
    // Panggilan ini akan membuat UI menampilkan loading indicator
    // karena (isLoading && teachers.isEmpty) akan bernilai true.
    notifyListeners();

    try {
      // 1. Ambil data mentah dari repository
      _teachers = await _teacherRepository.getTeachers();

      // 2. Panggil method internal untuk mengisi _filteredTeachers
      // dari _teachers yang baru saja di-fetch.
      _applyFilterAndSort();

    } catch (e) {
      _error = e.toString();
      _teachers.clear();       // Kosongkan daftar jika error
      _filteredTeachers.clear(); // Kosongkan juga daftar filter
    } finally {
      _isLoading = false;
      // 3. Panggil notifyListeners() SEKALI di akhir proses.
      // Sekarang, isLoading sudah false dan _filteredTeachers sudah terisi.
      // UI akan menggambar ulang dan menampilkan daftar guru.
      notifyListeners();
    }
  }

  Future<void> addTeacher(Map<String, dynamic> newTeacher) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validasi sederhana
      if (newTeacher['username'] == null || newTeacher['username'].isEmpty) {
        throw Exception('Username tidak boleh kosong');
      }
      if (newTeacher['password'] == null || newTeacher['password'].length < 6) {
        throw Exception('Password minimal 6 karakter');
      }
      if (newTeacher['nip'] == null || newTeacher['nip'].isEmpty) {
        throw Exception('NIP tidak boleh kosong');
      }

      await _teacherRepository.createTeacher(newTeacher);
      await fetchTeachers(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTeacher(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _teacherRepository.updateTeacher(id, data);
      await fetchTeachers(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTeacher(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _teacherRepository.deleteTeacher(id);
      _teachers.removeWhere((teacher) => teacher.idUsers == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> downloadTeacherTemplate() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filePath = await _teacherRepository.downloadTemplate();
      return filePath;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNGSI PERBAIKAN UNTUK PROSES IMPORT
  // FUNGSI IMPORT YANG SUDAH DIPERBAIKI
  Future<String> importTeachers(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? importMessage;

    try {
      // Lakukan proses import
      importMessage = await _teacherRepository.importTeachers(filePath);
    } catch (importError) {
      // Jika import gagal, set error dan rethrow
      _error = importError.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    // Jika sampai sini, berarti import berhasil
    // Sekarang coba refresh data
    try {
      final newTeachers = await _teacherRepository.getTeachers();
      _teachers = newTeachers;
    } catch (fetchError) {
      // Jika fetch gagal, log saja, jangan ganggu pesan sukses
      print(
        "DEBUG: Import berhasil, namun gagal memuat ulang daftar guru. Error: $fetchError",
      );
    }

    // Reset loading state dan return pesan sukses
    _isLoading = false;
    notifyListeners();

    return importMessage;
  }

  void _applyFilterAndSort() {
    List<Teacher> tempTeachers = List.from(_teachers);

    // Filter berdasarkan nama
    if (_searchQuery.isNotEmpty) {
      tempTeachers = tempTeachers
          .where((teacher) => teacher.namaLengkap
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Urutkan
    if (_sortOrder == SortOrder.az) {
      tempTeachers.sort((a, b) => a.namaLengkap.toLowerCase().compareTo(b.namaLengkap.toLowerCase()));
    } else {
      tempTeachers.sort((a, b) => b.namaLengkap.toLowerCase().compareTo(a.namaLengkap.toLowerCase()));
    }

    _filteredTeachers = tempTeachers;
  }

  /// Method publik yang dipanggil dari UI untuk menerapkan filter.
  void applyFilters(String query, SortOrder order) {
    _searchQuery = query;
    _sortOrder = order;
    _applyFilterAndSort();
    notifyListeners(); // Beri tahu UI untuk update
  }

  /// Method publik untuk mereset filter.
  void resetFilters() {
    _searchQuery = '';
    _sortOrder = SortOrder.az;
    _applyFilterAndSort();
    notifyListeners(); // Beri tahu UI untuk update
  }
}
