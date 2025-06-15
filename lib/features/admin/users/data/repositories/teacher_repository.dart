import '../models/teacher_model.dart';
import '../services/teacher_service.dart';

class TeacherRepository {
  final TeacherService _teacherService = TeacherService();

  Future<List<Teacher>> getTeachers() async {
    return await _teacherService.getTeachers();
  }

  Future<void> createTeacher(Map<String, dynamic> data) async {
    return await _teacherService.createTeacher(data);
  }

  Future<void> updateTeacher(int id, Map<String, dynamic> data) async {
    return await _teacherService.updateTeacher(id, data);
  }

  Future<void> deleteTeacher(int id) async {
    return await _teacherService.deleteTeacher(id);
  }
    Future<String> downloadTemplate() async {
    return await _teacherService.downloadTemplateExcel();
  }
  Future<String> importTeachers(String filePath) async {
    return await _teacherService.importTeachersFromExcel(filePath);
  }
}