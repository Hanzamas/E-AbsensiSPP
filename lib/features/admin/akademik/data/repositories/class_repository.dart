import '../models/class_model.dart';
import '../services/class_service.dart';

class ClassRepository {
  final ClassService _service = ClassService();

  Future<List<ClassModel>> getAllClasses() async {
    return await _service.getAllClasses();
  }

  Future<void> createClass(ClassModel classData) async {
    try {
      return await _service.createClass(classData);
    } catch (e) {
      rethrow;
    }
  }

  Future<ClassModel> updateClass(int id, ClassModel classData) async {
    try {
      return await _service.updateClass(id, classData);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      return await _service.deleteClass(id);
    } catch (e) {
      rethrow;
    }
  }
}