import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// import halaman guru di sini
// import 'package:e_absensi/features/teacher/dashboard/pages/teacher_home.dart';

class TeacherRoutes {
  static final List<RouteBase> routes = [
    // Contoh route utama guru
    GoRoute(
      path: '/teacher/home',
      name: 'teacher-home',
      // pageBuilder: (context, state) => ...
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: Placeholder(), // Ganti dengan TeacherHomePage()
      ),
    ),
    // Tambahkan route guru lain di sini
  ];
} 