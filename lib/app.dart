import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/core/router/app_router.dart';
import 'package:e_absensi/features/shared/auth/provider/auth_provider.dart';

// Import baru untuk student dashboard
import 'package:e_absensi/features/student/dashboard/provider/student_provider.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_provider.dart';
import 'package:e_absensi/features/student/spp/presentation/spp_provider.dart';
import 'package:e_absensi/features/shared/profile/provider/profile_provider.dart';
import 'package:e_absensi/features/shared/settings/provider/settings_provider.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        // Student Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: StudentProvider(),
        ),
        // Attendance Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: AttendanceProvider(),
        ),
        // SPP Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: SppProvider(),
        ),
        // Profile Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: ProfileProvider(),
        ),
        // Settings Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: SettingsProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'E‑Absensi',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}