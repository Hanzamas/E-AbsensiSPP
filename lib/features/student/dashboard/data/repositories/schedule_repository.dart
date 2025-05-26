import '../services/schedule_service.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  static final ScheduleRepository _instance = ScheduleRepository._internal();
  late final ScheduleService _service;
  
  // Private constructor
  ScheduleRepository._internal() {
    _service = ScheduleService();
  }

  // Singleton factory
  factory ScheduleRepository() => _instance;

  Future<List<Schedule>> getSchedule() async {
    try {
      return await _service.getStudentSchedule();
    } catch (e) {
      // Jika error, return list kosong
      return [];
    }
  }
} 