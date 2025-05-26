import 'package:flutter/material.dart';
import '../data/models/spp_model.dart';
import '../data/repositories/spp_repository.dart';

class SppProvider extends ChangeNotifier {
  static final SppProvider _instance = SppProvider._internal();
  final SppRepository _repository = SppRepository();
  
  bool _isLoading = false;
  String? _error;
  List<SppModel> _sppHistory = [];
  String? _selectedMonth;

  // Private constructor
  SppProvider._internal();

  // Singleton factory
  factory SppProvider() => _instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SppModel> get sppHistory => _sppHistory;
  String? get selectedMonth => _selectedMonth;

  // Set selected month
  void setSelectedMonth(String month) {
    _selectedMonth = month;
    Future.microtask(() => notifyListeners());
    loadSppHistory();
  }

  // Load SPP history
  Future<void> loadSppHistory() async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      _sppHistory = await _repository.getSppHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Get SPP detail
  Future<SppModel?> getSppDetail(int id) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final result = await _repository.getSppDetail(id);
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
} 