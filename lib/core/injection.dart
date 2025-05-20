// lib/core/injection.dart
import 'package:get_it/get_it.dart';
import 'storage/secure_storage.dart';

// GetIt instance
final getIt = GetIt.instance;

void setupInjection() {
  // Core
  getIt.registerLazySingleton(() => SecureStorage());

  // Features - Student (akan diimplementasikan)
  // _setupStudentFeatures();

  // Features - Teacher (akan diimplementasikan)
  // _setupTeacherFeatures();

  // Features - Admin (akan diimplementasikan)
  // _setupAdminFeatures();
}

/* // Uncomment dan implement sesuai kebutuhan
void _setupStudentFeatures() {
  // Student Services
  getIt.registerLazySingleton(() => AttendanceService());
  getIt.registerLazySingleton(() => SppService());

  // Student Repositories
  getIt.registerLazySingleton(
    () => AttendanceRepository(getIt<AttendanceService>()),
  );
  getIt.registerLazySingleton(
    () => SppRepository(getIt<SppService>()),
  );
}

void _setupTeacherFeatures() {
  // akan diimplementasikan
}

void _setupAdminFeatures() {
  // akan diimplementasikan
}
*/