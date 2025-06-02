import '../service/teacher_dashboard_service.dart';
import '../model/user_profile_model.dart';
import '../model/schedule_model.dart';
import 'package:flutter/foundation.dart'; // ✅ Add this import too

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
    final List<dynamic> attendanceData = await _service.getAttendanceData();
    
    // ✅ Handle empty data gracefully
    if (attendanceData.isEmpty) {
      return {
        'total': 0,
        'hadir': 0,
        'alpha': 0,
        'sakit': 0,
        'izin': 0,
      };
    }

    // Process stats from attendance data
    int total = attendanceData.length;
    int hadir = attendanceData.where((item) => item['status'] == 'Hadir').length;
    int alpha = attendanceData.where((item) => item['status'] == 'Alpha').length;
    int sakit = attendanceData.where((item) => item['status'] == 'Sakit').length;
    int izin = attendanceData.where((item) => item['status'] == 'Izin').length;

    return {
      'total': total,
      'hadir': hadir,
      'alpha': alpha,
      'sakit': sakit,
      'izin': izin,
    };
  } catch (e) {
    debugPrint('📊 Repository getAttendanceStats error: $e');
    
    // ✅ Return zero stats instead of throwing error
    return {
      'total': 0,
      'hadir': 0,
      'alpha': 0,
      'sakit': 0,
      'izin': 0,
    };
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