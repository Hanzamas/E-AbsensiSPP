import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// import halaman admin di sini
// import 'package:e_absensi/features/admin/dashboard/pages/admin_home.dart';

class AdminRoutes {
  static final List<RouteBase> routes = [
    // Contoh route utama admin
    GoRoute(
      path: '/admin/home',
      name: 'admin-home',
      // pageBuilder: (context, state) => ...
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: Placeholder(), // Ganti dengan AdminHomePage()
      ),
    ),
    // Tambahkan route admin lain di sini
  ];
} 