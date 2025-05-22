import '../models/spp_model.dart';

class SppService {
  static final SppService _instance = SppService._internal();

  // Private constructor
  SppService._internal();

  // Singleton factory
  factory SppService() => _instance;

  // Fetch SPP history
  Future<List<SppModel>> getSppHistory() async {
    // TODO: Implement API call
    // Untuk sementara menggunakan data dummy
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      SppModel(
        id: 1,
        month: 'Januari 2023',
        amount: 500000,
        status: 'Lunas',
        date: '2023-01-10',
      ),
      SppModel(
        id: 2,
        month: 'Februari 2023',
        amount: 500000,
        status: 'Lunas',
        date: '2023-02-15',
      ),
      SppModel(
        id: 3,
        month: 'Maret 2023',
        amount: 500000,
        status: 'Belum Lunas',
        date: null,
      ),
    ];
  }

  // Get SPP detail
  Future<SppModel> getSppDetail(int id) async {
    // TODO: Implement API call to get SPP detail
    // Untuk sementara menggunakan data dummy
    await Future.delayed(const Duration(seconds: 1));
    
    if (id == 1) {
      return SppModel(
        id: 1,
        month: 'Januari 2023',
        amount: 500000,
        status: 'Lunas',
        date: '2023-01-10',
      );
    } else if (id == 2) {
      return SppModel(
        id: 2,
        month: 'Februari 2023',
        amount: 500000,
        status: 'Lunas',
        date: '2023-02-15',
      );
    } else {
      return SppModel(
        id: 3,
        month: 'Maret 2023',
        amount: 500000,
        status: 'Belum Lunas',
        date: null,
      );
    }
  }
} 