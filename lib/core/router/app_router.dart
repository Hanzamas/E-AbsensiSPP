// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_guards.dart';

// Auth Pages
import 'package:e_absensi/features/shared/auth/pages/splash/splash_screen.dart';
import 'package:e_absensi/features/shared/auth/pages/login/login_page.dart';
import 'package:e_absensi/features/shared/auth/pages/register/register_page.dart';
import 'package:e_absensi/features/shared/auth/pages/terms/terms_and_condition.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/forgotpass_page.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/otp_page.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/changepass_page.dart';

// Student Pages
import 'package:e_absensi/features/student/dashboard/pages/student_home_page.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_screen.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_scan.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_success.dart';
import 'package:e_absensi/features/student/spp/presentation/spp_page.dart';
import 'package:e_absensi/features/student/spp/presentation/spp_detail_page.dart';

// Shared Pages
import 'package:e_absensi/features/shared/profile/pages/profile_main_page.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_edit_page.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_success_page.dart';
import 'package:e_absensi/features/shared/profile/pages/account_edit_page.dart';
import 'package:e_absensi/features/shared/settings/pages/settings_page.dart';

// // Shared Pages
// import '../../features/shared/profile/presentation/profile_page.dart';
// import '../../features/shared/profile/presentation/edit_profile_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: RouteGuards.authGuard, // Uncomment setelah implement route guard
    routes: [
      // Public Routes (Auth)
      ..._publicRoutes,
      
      // Student Routes
      ..._studentRoutes,
      
      /* // Teacher Routes (belum diimplementasikan)
      ..._teacherRoutes,
      
      // Admin Routes (belum diimplementasikan)
      ..._adminRoutes,
      */
      
      // Shared Routes
      ..._sharedRoutes,
    ],
  );

  // Public Routes
  static final List<RouteBase> _publicRoutes = [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => TermsAndConditionsPage(
        source: state.extra as String? ?? 'login',
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) => OtpPage(
        email: state.extra as String,
      ),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => ChangePasswordPage(
        email: state.extra as String,
      ),
    ),
  ];

  // Student Routes
  static final List<RouteBase> _studentRoutes = [
    GoRoute(
      path: '/student/home',
      name: 'student-home',
      builder: (context, state) => const StudentHomePage(),
    ),
    GoRoute(
      path: '/student/attendance',
      name: 'student-attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/student/attendance/scan',
      name: 'student-attendance-scan',
      builder: (context, state) => const AttendanceQr(),
    ),
    GoRoute(
      path: '/student/attendance/success',
      name: 'student-attendance-success',
      builder: (context, state) {
        // Defaultnya jika tidak ada data yang diberikan
        String subject = 'Matematika';
        String date = '15/10/2023';
        String time = '08:30';
        String status = 'Hadir';
        
        // Cek apakah ada data dari extra
        if (state.extra != null && state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          subject = data['subject'] as String? ?? subject;
          date = data['date'] as String? ?? date;
          time = data['time'] as String? ?? time;
          status = data['status'] as String? ?? status;
        }
        
        return AttendanceSuccess(
          subject: subject,
          date: date,
          time: time,
          status: status,
        );
      },
    ),
    GoRoute(
      path: '/student/spp',
      name: 'student-spp',
      builder: (context, state) => const SppPage(),
    ),
    GoRoute(
      path: '/student/spp/detail/:id',
      name: 'student-spp-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '0';
        return SppDetailPage(
          bulan: 'Pembayaran SPP ${id}',
          lunas: id == '1' || id == '2', // Anggap id 1 dan 2 sudah lunas
        );
      },
    ),
  ];

  /* // Teacher Routes (belum diimplementasikan)
  static final List<RouteBase> _teacherRoutes = [
    GoRoute(
      path: '/teacher/home',
      name: 'teacher-home',
      builder: (context, state) => const TeacherHomePage(),
    ),
  ];

  // Admin Routes (belum diimplementasikan)
  static final List<RouteBase> _adminRoutes = [
    GoRoute(
      path: '/admin/home',
      name: 'admin-home',
      builder: (context, state) => const AdminHomePage(),
    ),
  ];
  */

  // Shared Routes (bisa diakses semua role setelah login)
  static final List<RouteBase> _sharedRoutes = [
    // Rute profil untuk semua role
    GoRoute(
      path: '/:role/profile',
      name: 'profile',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        return ProfileMainPage(userRole: role);
      },
    ),
    GoRoute(
      path: '/:role/profile/edit',
      name: 'profile-edit',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        final isFromLogin = state.extra as bool? ?? false;
        return ProfileEditPage(isFromLogin: isFromLogin, userRole: role);
      },
    ),
    GoRoute(
      path: '/:role/profile/edit-account',
      name: 'profile-edit-account',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        return AccountEditPage(userRole: role);
      },
    ),
    GoRoute(
      path: '/:role/settings',
      name: 'settings',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        return SettingsPage(userRole: role);
      },
    ),
    GoRoute(
      path: '/:role/profile/success',
      name: 'profile-success',
      builder: (context, state) => const ProfileSuccessPage(),
    ),
  ];
}