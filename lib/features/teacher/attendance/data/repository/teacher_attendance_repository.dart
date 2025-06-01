import '../service/teacher_attendance_service.dart';
import '../model/teaching_schedule_model.dart';
import '../model/learning_session_model.dart';
import '../model/attendance_record_model.dart';

class TeacherAttendanceRepository {
  final TeacherAttendanceService _service = TeacherAttendanceService();

  /// Get teaching schedule
  Future<List<TeachingScheduleModel>> getTeachingSchedule() async {
    try {
      final rawData = await _service.getTeachingSchedule();
      return rawData
          .map((json) => TeachingScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Repository Error - getTeachingSchedule: $e');
    }
  }

  /// Create learning session
  Future<LearningSessionModel> createLearningSession(int idPengajaran) async {
    try {
      final rawData = await _service.createLearningSession(idPengajaran);
      return LearningSessionModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Repository Error - createLearningSession: $e');
    }
  }

  /// Get attendance history
  Future<List<AttendanceRecordModel>> getAttendanceHistory() async {
    try {
      final rawData = await _service.getAttendanceHistory();
      return rawData
          .map((json) => AttendanceRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Repository Error - getAttendanceHistory: $e');
    }
  }

  /// Get attendance by ID
  Future<AttendanceRecordModel> getAttendanceById(int id) async {
    try {
      final rawData = await _service.getAttendanceById(id);
      return AttendanceRecordModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Repository Error - getAttendanceById: $e');
    }
  }

  /// Update attendance status
  Future<Map<String, dynamic>> updateAttendanceStatus(
    int id, 
    String status, 
    String? keterangan
  ) async {
    try {
      return await _service.updateAttendanceStatus(id, status, keterangan);
    } catch (e) {
      throw Exception('Repository Error - updateAttendanceStatus: $e');
    }
  }

  /// Get today's teaching schedule
  Future<List<TeachingScheduleModel>> getTodaySchedule() async {
    try {
      final allSchedules = await getTeachingSchedule();
      return allSchedules.where((schedule) => schedule.isToday).toList();
    } catch (e) {
      throw Exception('Repository Error - getTodaySchedule: $e');
    }
  }

  /// Get attendance by date range
  Future<List<AttendanceRecordModel>> getAttendanceByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final allRecords = await getAttendanceHistory();
      return allRecords.where((record) {
        return record.tanggal.isAfter(startDate.subtract(const Duration(days: 1))) &&
               record.tanggal.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Repository Error - getAttendanceByDateRange: $e');
    }
  }

  /// Get today's attendance only
  Future<List<AttendanceRecordModel>> getTodayAttendance() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      return await getAttendanceByDateRange(startOfDay, endOfDay);
    } catch (e) {
      throw Exception('Repository Error - getTodayAttendance: $e');
    }
  }

  /// Get attendance stats
  Future<Map<String, int>> getAttendanceStats([DateTime? date]) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
      
      final attendanceList = await getAttendanceByDateRange(startOfDay, endOfDay);
      
      return {
        'total': attendanceList.length,
        'hadir': attendanceList.where((a) => a.isPresent).length,
        'alpha': attendanceList.where((a) => a.isAbsent).length,
        'sakit': attendanceList.where((a) => a.isSick).length,
        'izin': attendanceList.where((a) => a.isPermission).length,
      };
    } catch (e) {
      throw Exception('Repository Error - getAttendanceStats: $e');
    }
  }

  /// Get available subjects for filter
  Future<List<String>> getAvailableSubjects() async {
    try {
      final allRecords = await getAttendanceHistory();
      return allRecords
          .map((record) => record.namaMapel)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      throw Exception('Repository Error - getAvailableSubjects: $e');
    }
  }

  /// Get available classes for filter
  Future<List<String>> getAvailableClasses() async {
    try {
      final allRecords = await getAttendanceHistory();
      return allRecords
          .map((record) => record.namaKelas)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      throw Exception('Repository Error - getAvailableClasses: $e');
    }
  }
}