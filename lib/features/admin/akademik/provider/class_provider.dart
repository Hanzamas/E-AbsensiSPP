import 'package:flutter/material.dart';
import '../data/repositories/class_repository.dart';
import '../data/models/class_model.dart';
import '../data/models/academic_year_model.dart';
import '../data/repositories/academic_year_repository.dart';
import '../../users/widgets/filter_and_sort_widget.dart';


class ClassProvider extends ChangeNotifier {
  final ClassRepository _repository = ClassRepository();
  final AcademicYearRepository _academicYearRepository = AcademicYearRepository();

  bool _isLoading = false;
  String? _error;
  
  List<ClassModel> _classes = []; // Daftar master
  List<ClassModel> _filteredClasses = []; // Daftar untuk UI
  List<AcademicYearModel> _academicYears = [];

  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.az;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassModel> get classes => _filteredClasses;
  List<AcademicYearModel> get academicYears => _academicYears;
  bool get isFilterActive => _searchQuery.isNotEmpty;
  bool get isMasterListEmpty => _classes.isEmpty;

  void _applyFilterAndSort() {
    _filteredClasses = List.from(_classes);

    // Filter berdasarkan nama kelas
    if (_searchQuery.isNotEmpty) {
      _filteredClasses = _filteredClasses
          .where((classData) => classData.namaKelas
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Urutkan
    _filteredClasses.sort((a, b) {
      final comparison = a.namaKelas.toLowerCase().compareTo(b.namaKelas.toLowerCase());
      return _sortOrder == SortOrder.az ? comparison : -comparison;
    });

  }

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

  Future<void> loadClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getAllClasses(),
        _academicYearRepository.getAllAcademicYears(),
      ]);

      _classes = results[0] as List<ClassModel>;
      _academicYears = results[1] as List<AcademicYearModel>;
      _applyFilterAndSort();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading classes or academic years: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAcademicYears() async {
    if (_academicYears.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _academicYears = await _academicYearRepository.getAllAcademicYears();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(ClassModel classData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createClass(classData);
      await loadClasses(); // Muat ulang dan filter
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(int id, ClassModel classData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedClass = await _repository.updateClass(id, classData);
      final index = _classes.indexWhere((c) => c.id == id);

      if (index != -1) {
        final preservedClass = ClassModel(
          id: updatedClass.id,
          namaKelas: updatedClass.namaKelas,
          kapasitas: updatedClass.kapasitas,
          idTahunAjaran: updatedClass.idTahunAjaran,
          tahunAjaran: updatedClass.tahunAjaran.isEmpty
              ? _classes[index].tahunAjaran
              : updatedClass.tahunAjaran,
        );
        _classes[index] = preservedClass;
        _applyFilterAndSort(); // Filter ulang
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClass(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _repository.deleteClass(id);
      if (success) {
        _classes.removeWhere((c) => c.id == id);
        _applyFilterAndSort(); // Filter ulang
      }
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}