import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/core/router/app_router.dart';
import 'package:e_absensi/features/shared/auth/provider/auth_provider.dart';

// Import baru untuk student dashboard
import 'package:e_absensi/features/student/dashboard/provider/home_provider.dart';
import 'package:e_absensi/features/student/attendance/provider/attendance_provider.dart';
import 'package:e_absensi/features/student/spp/provider/spp_provider.dart';
import 'package:e_absensi/features/shared/profile/provider/profile_provider.dart';

import 'package:e_absensi/features/shared/settings/provider/settings_provider.dart';


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Inisialisasi data profile dari cache saat aplikasi pertama dimuat
    
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        // Home Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: HomeProvider(),
        ),
        // Attendance Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: AttendanceProvider(),
        ),
        // // SPP Provider - menggunakan singleton pattern
        // ChangeNotifierProvider.value(
        //   value: SppProvider(),
        // ),
        // Profile Provider - menggunakan singleton pattern
        ChangeNotifierProvider.value(
          value: ProfileProvider(),
        ),
        // Profile Photo Provider - menggunakan singleton pattern
        
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