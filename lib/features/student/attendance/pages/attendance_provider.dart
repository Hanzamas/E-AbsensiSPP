import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  static final AttendanceProvider _instance = AttendanceProvider._internal();
  
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _attendanceHistory = [];

  // Private constructor
  AttendanceProvider._internal();

  // Singleton factory
  factory AttendanceProvider() => _instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get attendanceHistory => _attendanceHistory;

  // Load attendance history
  Future<void> loadAttendanceHistory() async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      // Dummy data (akan diganti dengan API call nanti)
      await Future.delayed(const Duration(seconds: 1));
      
      _attendanceHistory = [
        {
          'id': 1,
          'date': '2023-10-15',
          'subject': 'Matematika',
          'status': 'Hadir',
          'time': '07:30',
        },
        {
          'id': 2,
          'date': '2023-10-16',
          'subject': 'Bahasa Indonesia',
          'status': 'Hadir',
          'time': '09:15',
        },
        {
          'id': 3,
          'date': '2023-10-17',
          'subject': 'Bahasa Inggris',
          'status': 'Izin',
          'time': '08:00',
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
