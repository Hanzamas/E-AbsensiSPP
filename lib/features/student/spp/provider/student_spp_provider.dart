import 'package:flutter/material.dart';
import 'dart:async';
import '../data/models/spp_model.dart';
import '../data/repositories/student_spp_repository.dart';

class StudentSppProvider extends ChangeNotifier {
  static final StudentSppProvider _instance = StudentSppProvider._internal();
  final StudentSppRepository _repository = StudentSppRepository();

  StudentSppProvider._internal();

  factory StudentSppProvider() => _instance;

  // Loading states
  bool _isLoadingBills = false;
  bool _isLoadingHistory = false;
  bool _isCreatingPayment = false;
  String? _error;

  // Data
  List<SppBillModel> _unpaidBills = [];
  List<PaymentHistoryModel> _paymentHistory = [];
  QrisPaymentModel? _currentQris;
  
  // Timer for QRIS expiration
  Timer? _qrisTimer;
  Duration _qrisTimeRemaining = Duration.zero;

  // Getters
  bool get isLoading => isLoadingBills || isLoadingHistory || isCreatingPayment;
  bool get isLoadingBills => _isLoadingBills;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isCreatingPayment => _isCreatingPayment;
  String? get error => _error;
  List<SppBillModel> get unpaidBills => _unpaidBills;
  List<PaymentHistoryModel> get paymentHistory => _paymentHistory;
  QrisPaymentModel? get currentQris => _currentQris;
  Duration get qrisTimeRemaining => _qrisTimeRemaining;

  // ✅ Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadUnpaidBills(),
      loadPaymentHistory(),
    ]);
  }

  // ✅ Load unpaid bills
  Future<void> loadUnpaidBills() async {
    try {
      _setLoadingBills(true);
      _error = null;

      final result = await _repository.getUnpaidSppBills();
      _unpaidBills = result;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading unpaid bills: $e');
    } finally {
      _setLoadingBills(false);
    }
  }
  

  // ✅ Load payment history
  Future<void> loadPaymentHistory() async {
    try {
      _setLoadingHistory(true);
      final result = await _repository.getPaymentHistory();
      _paymentHistory = result;
    } catch (e) {
      debugPrint('Error loading payment history: $e');
    } finally {
      _setLoadingHistory(false);
    }
  }

  // ✅ Create QRIS payment
  Future<bool> createQrisPayment(int billId) async {
    try {
      _setCreatingPayment(true);
      _error = null;

      final result = await _repository.createQrisPayment(billId);
      _currentQris = result;
      
      // Start countdown timer for QRIS expiration (5 minutes)
      _startQrisTimer();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating QRIS payment: $e');
      return false;
    } finally {
      _setCreatingPayment(false);
    }
  }

  // ✅ Start QRIS expiration timer
  void _startQrisTimer() {
    _qrisTimer?.cancel();
    
    if (_currentQris != null) {
      final now = DateTime.now();
      final expiry = _currentQris!.expiresAt;
      _qrisTimeRemaining = expiry.difference(now);
      
      if (_qrisTimeRemaining.isNegative) {
        _qrisTimeRemaining = Duration.zero;
        return;
      }
      
      _qrisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _qrisTimeRemaining = _qrisTimeRemaining - const Duration(seconds: 1);
        
        if (_qrisTimeRemaining.isNegative || _qrisTimeRemaining == Duration.zero) {
          _qrisTimeRemaining = Duration.zero;
          timer.cancel();
          _currentQris = null;
        }
        
        notifyListeners();
      });
    }
  }

  // ✅ Clear current QRIS
  void clearCurrentQris() {
    _qrisTimer?.cancel();
    _currentQris = null;
    _qrisTimeRemaining = Duration.zero;
    notifyListeners();
  }

  // ✅ Get SPP statistics
  Map<String, dynamic> getSppStats() {
    final totalAmount = _unpaidBills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
    final totalFine = _unpaidBills.fold(0.0, (sum, bill) => sum + bill.denda);
    
    return {
      'total_bills': _unpaidBills.length,
      'total_amount': totalAmount,
      'total_fine': totalFine,
      'overdue_bills': _unpaidBills.where((bill) => 
        DateTime.now().isAfter(bill.dueDate) && bill.status == 'terhutang'
      ).length,
    };
  }

  // ✅ Get bills by year
  Map<String, List<SppBillModel>> getBillsByYear() {
    final Map<String, List<SppBillModel>> groupedBills = {};
    
    for (final bill in _unpaidBills) {
      if (!groupedBills.containsKey(bill.tahun)) {
        groupedBills[bill.tahun] = [];
      }
      groupedBills[bill.tahun]!.add(bill);
    }
    
    // Sort by year descending
    final sortedKeys = groupedBills.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <String, List<SppBillModel>>{};
    
    for (final key in sortedKeys) {
      // Sort bills by month
      groupedBills[key]!.sort((a, b) => int.parse(a.bulan).compareTo(int.parse(b.bulan)));
      sortedMap[key] = groupedBills[key]!;
    }
    
    return sortedMap;
  }

  // Helper methods
  void _setLoadingBills(bool value) {
    _isLoadingBills = value;
    notifyListeners();
  }

  void _setLoadingHistory(bool value) {
    _isLoadingHistory = value;
    notifyListeners();
  }

  void _setCreatingPayment(bool value) {
    _isCreatingPayment = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ✅ Refresh data
  Future<bool> refresh() async {
    try {
      await loadInitialData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _qrisTimer?.cancel();
    super.dispose();
  }
  
}
