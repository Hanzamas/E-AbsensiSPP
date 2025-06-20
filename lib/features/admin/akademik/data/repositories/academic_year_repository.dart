import '../models/academic_year_model.dart';
import '../services/academic_year_service.dart';

class AcademicYearRepository {
  final AcademicYearService _service = AcademicYearService();

    Future<List<AcademicYearModel>> getAllAcademicYears() async {
    return await _service.getAllAcademicYears();
  }

  Future<AcademicYearModel> createAcademicYear(AcademicYearModel academicYear) async {
    try {
      return await _service.createAcademicYear(academicYear);
    } catch (e) {
      rethrow;
    }
  }

    // Method untuk update tahun ajaran (BARU)
  Future<void> updateAcademicYear(int id, AcademicYearModel academicYear) async {
    return await _service.updateAcademicYear(id, academicYear.toJson());
  }

  // Method untuk hapus tahun ajaran (BARU)
  Future<void> deleteAcademicYear(int id) async {
    return await _service.deleteAcademicYear(id);
  }

}