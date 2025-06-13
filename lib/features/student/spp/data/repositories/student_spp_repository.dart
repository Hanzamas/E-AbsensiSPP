import '../services/student_spp_service.dart';
import '../models/spp_model.dart';

class StudentSppRepository {
  static final StudentSppRepository _instance = StudentSppRepository._internal();
  late final StudentSppService _service;

  StudentSppRepository._internal() {
    _service = StudentSppService();
  }

  factory StudentSppRepository() => _instance;

  // ✅ Get unpaid SPP bills
  Future<List<SppBillModel>> getUnpaidSppBills() async {
    try {
      final response = await _service.getUnpaidSppBills();
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => SppBillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  // ✅ Create QRIS payment
  Future<QrisPaymentModel> createQrisPayment(int billId) async {
    try {
      final response = await _service.createQrisPayment(billId);
      return QrisPaymentModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  // ✅ Get payment history
  Future<List<PaymentHistoryModel>> getPaymentHistory() async {
    try {
      final response = await _service.getPaymentHistory();
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PaymentHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}