import '../models/subject_model.dart';
import '../services/subject_service.dart';

class SubjectRepository {
  final _service = SubjectService();

  Future<List<SubjectModel>> getAllSubjects() async {
    return await _service.getAllSubjects();
  }

  Future<void> createSubject(SubjectModel subject) async {
    await _service.createSubject(subject);
  }

  Future<SubjectModel> updateSubject(int id, SubjectModel subject) async {
    return await _service.updateSubject(id, subject);
  }

  Future<bool> deleteSubject(int id) async {
    return await _service.deleteSubject(id);
  }
}
