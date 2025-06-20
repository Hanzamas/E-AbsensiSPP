// admin/akademik/data/repositories/teaching_repository.dart

import '../models/teaching_model.dart';
import '../services/teaching_service.dart';

class TeachingRepository {
  final TeachingService _service = TeachingService();

  Future<List<TeachingModel>> getAllTeachings() => _service.getAllTeachings();
  Future<void> createTeaching(Map<String, dynamic> data) => _service.createTeaching(data);
  Future<void> updateTeaching(int id, Map<String, dynamic> data) => _service.updateTeaching(id, data);
  Future<void> deleteTeaching(int id) => _service.deleteTeaching(id);
}