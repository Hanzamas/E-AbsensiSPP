import 'package:flutter/material.dart';

class SppProvider extends ChangeNotifier {
  static final SppProvider _instance = SppProvider._internal();
  
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _sppHistory = [];
  String? _selectedMonth;

  // Private constructor
  SppProvider._internal();

  // Singleton factory
  factory SppProvider() => _instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get sppHistory => _sppHistory;
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

      // Dummy data (akan diganti dengan API call nanti)
      await Future.delayed(const Duration(seconds: 1));
      
      _sppHistory = [
        {
          'id': 1,
          'month': 'Januari 2023',
          'amount': 500000,
          'status': 'Lunas',
          'date': '2023-01-10',
        },
        {
          'id': 2,
          'month': 'Februari 2023',
          'amount': 500000,
          'status': 'Lunas',
          'date': '2023-02-15',
        },
        {
          'id': 3,
          'month': 'Maret 2023',
          'amount': 500000,
          'status': 'Belum Lunas',
          'date': null,
        },
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
} 