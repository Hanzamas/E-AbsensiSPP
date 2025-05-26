// import 'package:flutter/material.dart';
// import '../data/models/attendance_model.dart';
// import '../data/repositories/attendance_repository.dart';

// class AttendanceProvider extends ChangeNotifier {
//   static final AttendanceProvider _instance = AttendanceProvider._internal();
//   final AttendanceRepository _repository = AttendanceRepository();
  
//   bool _isLoading = false;
//   String? _error;
//   List<AttendanceModel> _attendanceHistory = [];
//   Map<String, dynamic>? _submissionResult;

//   // Private constructor
//   AttendanceProvider._internal();

//   // Singleton factory
//   factory AttendanceProvider() => _instance;

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   List<AttendanceModel> get attendanceHistory => _attendanceHistory;
//   Map<String, dynamic>? get submissionResult => _submissionResult;

//   // Load attendance history
//   Future<void> loadAttendanceHistory() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       _attendanceHistory = await _repository.getAttendanceHistory();
//     } catch (e) {
//       _error = e.toString();
//       print('Error loading attendance: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Submit attendance
//   Future<bool> submitAttendance(String qrCode) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       _submissionResult = null;
//       notifyListeners();

//       final result = await _repository.submitAttendance(qrCode);
//       _submissionResult = result;
      
//       // Refresh attendance history after successful submission
//       await loadAttendanceHistory();
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       print('Error submitting attendance: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Clear submission result
//   void clearSubmissionResult() {
//     _submissionResult = null;
//     notifyListeners();
//   }

//   // Get submission data
//   Map<String, dynamic>? getSubmissionData() {
//     return _submissionResult?['data'];
//   }

//   // Refresh data
//   Future<bool> refresh() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
      
//       _attendanceHistory = await _repository.getAttendanceHistory();
      
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
// } 