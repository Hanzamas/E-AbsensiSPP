import 'package:flutter/material.dart';
import '../data/models/student.dart';
import '../data/models/schedule.dart';
import '../data/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  static final StudentProvider _instance = StudentProvider._internal();
  late final StudentRepository _repository;
  
  Student? _student;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  String? _updateError;

  // Private constructor
  StudentProvider._internal() {
    _repository = StudentRepository();
  }

  // Singleton factory
  factory StudentProvider() => _instance;

  // Getters
  Student? get student => _student;
  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  String? get updateError => _updateError;

  // Load profile data
  Future<void> loadProfile() async {
    if (_isLoading) return; // Hindari panggilan berulang selama proses loading
    
    _isLoading = true;
    _error = null;
    // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
    Future.microtask(() => notifyListeners());

    try {
      _student = await _repository.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
      Future.microtask(() => notifyListeners());
    }
  }

  // Load schedule data
  Future<void> loadSchedule() async {
    if (_isLoading) return; // Hindari panggilan berulang selama proses loading
    
    _isLoading = true;
    _error = null;
    // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
    Future.microtask(() => notifyListeners());

    try {
      _schedules = await _repository.getSchedule();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
      Future.microtask(() => notifyListeners());
    }
  }

  // Update profile data
  Future<bool> updateProfile({
    required int idKelas,
    required String nis,
    required String namaLengkap,
    required String jenisKelamin,
    required String tanggalLahir,
    required String tempatLahir,
    required String alamat,
    required String wali,
    required String waWali,
  }) async {
    if (_isUpdating) return false; // Hindari panggilan berulang selama proses loading
    
    _isUpdating = true;
    _updateError = null;
    // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
    Future.microtask(() => notifyListeners());

    try {
      await _repository.updateProfile(
        idKelas: idKelas,
        nis: nis,
        namaLengkap: namaLengkap,
        jenisKelamin: jenisKelamin,
        tanggalLahir: tanggalLahir,
        tempatLahir: tempatLahir,
        alamat: alamat,
        wali: wali,
        waWali: waWali,
      );
      
      // Reload profile after update
      await loadProfile();
      return true;
    } catch (e) {
      _updateError = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      // Pindahkan notifyListeners ke Future.microtask untuk menghindari panggilan selama build
      Future.microtask(() => notifyListeners());
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadProfile(),
      loadSchedule(),
    ]);
  }
}