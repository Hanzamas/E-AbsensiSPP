import '../service/teacher_dashboard_service.dart';
import '../model/user_profile_model.dart';
import '../model/schedule_model.dart';

class TeacherDashboardRepository {
  final TeacherDashboardService _service = TeacherDashboardService();

  Future<UserProfileModel> getUserProfile() async {
    try {
      final rawData = await _service.getUserProfile();
      return UserProfileModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Repository Error - getUserProfile: $e');
    }
  }

  Future<List<ScheduleModel>> getTodaySchedule() async {
    try {
      final rawData = await _service.getTeachingSchedule();
      final allSchedules = rawData
          .map((json) => ScheduleModel.fromJson(json))
          .toList();
      
      return allSchedules.where((schedule) => schedule.isToday).toList();
    } catch (e) {
      throw Exception('Repository Error - getTodaySchedule: $e');
    }
  }

  Future<Map<String, int>> getAttendanceStats() async {
    try {
      final rawData = await _service.getAttendanceData();
      final today = DateTime.now();
      
      final todayAttendance = rawData.where((record) {
        try {
          final recordDate = DateTime.parse(record['tanggal']);
          return recordDate.year == today.year &&
                 recordDate.month == today.month &&
                 recordDate.day == today.day;
        } catch (e) {
          return false;
        }
      }).toList();

      return {
        'total': todayAttendance.length,
        'hadir': todayAttendance.where((r) => r['status']?.toString().toLowerCase() == 'hadir').length,
        'alpha': todayAttendance.where((r) => r['status']?.toString().toLowerCase() == 'alpha').length,
        'sakit': todayAttendance.where((r) => r['status']?.toString().toLowerCase() == 'sakit').length,
        'izin': todayAttendance.where((r) => r['status']?.toString().toLowerCase() == 'izin').length,
      };
    } catch (e) {
      throw Exception('Repository Error - getAttendanceStats: $e');
    }
  }

  Future<Map<String, dynamic>> startSession(int idPengajaran) async {
    try {
      return await _service.startLearningSession(idPengajaran);
    } catch (e) {
      throw Exception('Repository Error - startSession: $e');
    }
  }
}