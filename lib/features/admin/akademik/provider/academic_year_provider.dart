import 'package:flutter/material.dart';
import '../data/models/academic_year_model.dart';
import '../data/repositories/academic_year_repository.dart';

class AcademicYearProvider extends ChangeNotifier {
  final AcademicYearRepository _repository = AcademicYearRepository();
  bool _isLoading = false;
  String? _error;
  List<AcademicYearModel> _academicYears = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AcademicYearModel> get academicYears => _academicYears;

  // Method untuk memuat daftar tahun ajaran (BARU)
  Future<void> fetchAcademicYears() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _academicYears = await _repository.getAllAcademicYears();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAcademicYear(AcademicYearModel academicYear) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createAcademicYear(academicYear);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Method untuk update tahun ajaran (BARU)
  Future<bool> updateAcademicYear(int id, AcademicYearModel academicYear) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateAcademicYear(id, academicYear);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk hapus tahun ajaran (BARU)
  Future<bool> deleteAcademicYear(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAcademicYear(id);
      // Hapus dari list lokal untuk update UI instan
      _academicYears.removeWhere((year) => year.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      // Jika gagal, muat ulang data dari server untuk konsistensi
      await fetchAcademicYears(); 
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}