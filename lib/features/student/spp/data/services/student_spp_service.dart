import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';

class StudentSppService {
  static final StudentSppService _instance = StudentSppService._internal();
  late final Dio _dio;

  StudentSppService._internal() {
    _dio = DioClient().dio; // AuthInterceptor already configured
  }

  factory StudentSppService() => _instance;

  // ✅ Get unpaid SPP bills
  Future<Map<String, dynamic>> getUnpaidSppBills() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudentSppBill);

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil tagihan SPP');
      }
    } catch (e) {
      throw Exception('Gagal mengambil tagihan SPP: $e');
    }
  }

  // ✅ Create QRIS payment
  Future<Map<String, dynamic>> createQrisPayment(int billId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.payStudentSpp,
        data: {'bill_id': billId},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat kode QRIS');
      }
    } catch (e) {
      throw Exception('Gagal membuat kode QRIS: $e');
    }
  }

  // ✅ Get payment history
  Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.getStudentPaymentHistory);

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil histori pembayaran');
      }
    } catch (e) {
      throw Exception('Gagal mengambil histori pembayaran: $e');
    }
  }
}