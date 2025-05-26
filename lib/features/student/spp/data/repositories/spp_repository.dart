import '../models/spp_model.dart';
import '../services/spp_service.dart';

class SppRepository {
  static final SppRepository _instance = SppRepository._internal();
  final SppService _service = SppService();

  // Private constructor
  SppRepository._internal();

  // Singleton factory
  factory SppRepository() => _instance;

  // Mendapatkan riwayat SPP
  Future<List<SppModel>> getSppHistory() async {
    return await _service.getSppHistory();
  }

  // Mendapatkan detail SPP
  Future<SppModel> getSppDetail(int id) async {
    return await _service.getSppDetail(id);
  }
} 