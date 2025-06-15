import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// Import the content widgets for each admin section
import 'package:e_absensi/features/admin/dashboard/pages/admin_home_screen.dart';
import 'package:e_absensi/features/admin/akademik/pages/akademik_screen.dart';
import 'package:e_absensi/features/admin/users/pages/users_screen.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_main_page.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/features/admin/users/provider/teacher_provider.dart';

class AdminRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: '/admin/home',
      name: 'admin-home',
      pageBuilder:
          (context, state) =>
              const NoTransitionPage<void>(child: AdminHomeScreen()),
    ),
    GoRoute(
      path: '/admin/akademik',
      name: 'admin-akademik',
      pageBuilder:
          (context, state) =>
              const NoTransitionPage<void>(child: AdminAkademikScreen()),
    ),
    GoRoute(
      path: '/admin/users',
      name: 'admin-users',
      // Gunakan pageBuilder seperti yang Anda miliki
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            // Bungkus AdminUsersScreen dengan ChangeNotifierProvider di sini
            child: ChangeNotifierProvider(
              create: (_) => TeacherProvider(),
              child: const AdminUsersScreen(),
            ),
          ),
    ),
    GoRoute(
      path: '/admin/profile',
      name: 'admin-profile',
      pageBuilder:
          (context, state) => const NoTransitionPage<void>(
            child: ProfileMainPage(userRole: 'admin'),
          ),
    ),
    // Add any other top-level admin routes here if needed
  ];
}
