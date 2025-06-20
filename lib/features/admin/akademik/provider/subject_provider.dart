import 'package:flutter/material.dart';
import '../data/models/subject_model.dart';
import '../data/repositories/subject_repository.dart';
import '../../users/widgets/filter_and_sort_widget.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectRepository _repository = SubjectRepository();
  
  bool _isLoading = false;
  String? _error;
  
  // Daftar master dari API
  List<SubjectModel> _subjects = [];
  // Daftar yang akan ditampilkan di UI setelah difilter/diurutkan
  List<SubjectModel> _filteredSubjects = [];

  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.az;

  // Getter yang digunakan oleh UI
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SubjectModel> get subjects => _filteredSubjects;
  
  // Getter untuk memeriksa apakah ada filter yang aktif
  bool get isFilterActive => _searchQuery.isNotEmpty;
  // Getter untuk memeriksa apakah daftar master kosong
  bool get isMasterListEmpty => _subjects.isEmpty;


  // Menerapkan filter dan urutan ke daftar master
  void _applyFilterAndSort() {
    _filteredSubjects = List.from(_subjects);

    // Filter berdasarkan nama
    if (_searchQuery.isNotEmpty) {
      _filteredSubjects = _filteredSubjects
          .where((subject) =>
              subject.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Urutkan
    _filteredSubjects.sort((a, b) {
      final comparison = a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
      return _sortOrder == SortOrder.az ? comparison : -comparison;
    });
  }

  // Method publik untuk dipanggil dari UI
  void applyFilters(String query, SortOrder order) {
    _searchQuery = query;
    _sortOrder = order;
    _applyFilterAndSort();
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _sortOrder = SortOrder.az;
    _applyFilterAndSort();
    notifyListeners();
  }


  Future<void> loadSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _subjects = await _repository.getAllSubjects();
      _applyFilterAndSort(); // Terapkan urutan awal
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading subjects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubject(SubjectModel subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createSubject(subject);
      await loadSubjects(); // Muat ulang semua data dan terapkan filter
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSubject(int id, SubjectModel subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedSubject = await _repository.updateSubject(id, subject);
      final index = _subjects.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subjects[index] = updatedSubject;
        _applyFilterAndSort(); // Terapkan filter ke data yang sudah diperbarui
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSubject(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _repository.deleteSubject(id);
      if (success) {
        _subjects.removeWhere((subject) => subject.id == id);
        _applyFilterAndSort(); // Terapkan filter setelah menghapus
      }
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}