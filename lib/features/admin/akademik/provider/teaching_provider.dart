import 'package:flutter/material.dart';
import '../data/models/teaching_model.dart';
import '../data/repositories/teaching_repository.dart';
import '../../users/data/models/teacher_model.dart';
import '../../users/data/repositories/teacher_repository.dart';
import '../data/models/class_model.dart';
import '../data/repositories/class_repository.dart';
import '../data/models/subject_model.dart';
import '../data/repositories/subject_repository.dart';
import 'dart:collection';

class TeachingProvider extends ChangeNotifier {
  final TeachingRepository _teachingRepo = TeachingRepository();
  final TeacherRepository _teacherRepo = TeacherRepository();
  final ClassRepository _classRepo = ClassRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();

  bool _isLoading = false;
  String? _error;

  List<TeachingModel> _teachings = [];
  List<Teacher> _teachers = [];
  List<ClassModel> _classes = [];
  List<SubjectModel> _subjects = [];

  // Getters
  // bool get isLoading => _isLoading;
  // String? get error => _error;
  // List<TeachingModel> get teachings => _teachings;
  // List<Teacher> get teachers => _teachers;
  // List<ClassModel> get classes => _classes;
  // List<SubjectModel> get subjects => _subjects;

    // --- PENAMBAHAN: Variabel untuk state filter ---
  int? _selectedFilterGuruId;
  int? _selectedFilterMapelId;
  int? _selectedFilterKelasId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TeachingModel> get teachings => _teachings;
  
  // Getter untuk data dropdown, dibuat Unmodifiable untuk keamanan
  UnmodifiableListView<Teacher> get teachers => UnmodifiableListView(_teachers);
  UnmodifiableListView<ClassModel> get classes => UnmodifiableListView(_classes);
  UnmodifiableListView<SubjectModel> get subjects => UnmodifiableListView(_subjects);

  // Getter untuk filter state
  int? get selectedFilterGuruId => _selectedFilterGuruId;
  int? get selectedFilterMapelId => _selectedFilterMapelId;
  int? get selectedFilterKelasId => _selectedFilterKelasId;
  bool get isFilterActive => _selectedFilterGuruId != null || _selectedFilterMapelId != null || _selectedFilterKelasId != null;

  // --- PENAMBAHAN: Getter untuk daftar yang sudah terfilter ---
  List<TeachingModel> get filteredTeachings {
    List<TeachingModel> result = _teachings;
    if (_selectedFilterGuruId != null) {
      result = result.where((t) => t.idGuru == _selectedFilterGuruId).toList();
    }
    if (_selectedFilterMapelId != null) {
      result = result.where((t) => t.idMapel == _selectedFilterMapelId).toList();
    }
    if (_selectedFilterKelasId != null) {
      result = result.where((t) => t.idKelas == _selectedFilterKelasId).toList();
    }
    return result;
  }
  // -----------------------------------------------------------

  void applyFilters({int? guruId, int? mapelId, int? kelasId}) {
    _selectedFilterGuruId = guruId;
    _selectedFilterMapelId = mapelId;
    _selectedFilterKelasId = kelasId;
    notifyListeners();
  }

  void clearFilters() {
    _selectedFilterGuruId = null;
    _selectedFilterMapelId = null;
    _selectedFilterKelasId = null;
    notifyListeners();
  }

  Future<void> loadAllTeachings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _teachings = await _teachingRepo.getAllTeachings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Memuat semua data yang diperlukan untuk dropdown di halaman 'Add/Edit Teaching'
  Future<void> loadDependencies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Memanggil semua data secara paralel
      final results = await Future.wait([
        _teacherRepo.getTeachers(),
        _classRepo.getAllClasses(),
        _subjectRepo.getAllSubjects(),
      ]);
      _teachers = results[0] as List<Teacher>;
      _classes = results[1] as List<ClassModel>;
      _subjects = results[2] as List<SubjectModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTeaching(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _teachingRepo.createTeaching(data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateTeaching(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _teachingRepo.updateTeaching(id, data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> deleteTeaching(int id) async {
    try {
      await _teachingRepo.deleteTeaching(id);
      _teachings.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}