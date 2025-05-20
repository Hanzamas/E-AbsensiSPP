// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_guards.dart';

// Auth Pages
import '../../features/shared/auth/pages/splash_screen.dart';
import '../../features/shared/auth/pages/login/login_page.dart';
import '../../features/shared/auth/pages/register/register_page.dart';
import '../../features/shared/auth/pages/terms_and_condition.dart';
import '../../features/shared/auth/pages/forgot_pass/forgotpass_page.dart';
import '../../features/shared/auth/pages/forgot_pass/otp_page.dart';
import '../../features/shared/auth/pages/forgot_pass/changepass_page.dart';

// // Student Pages
// import '../../features/student/home/presentation/student_home_page.dart';
// import '../../features/student/attendance/presentation/attendance_page.dart';
// import '../../features/student/attendance/presentation/scan_qr_page.dart';
// import '../../features/student/spp/presentation/spp_page.dart';
// import '../../features/student/spp/presentation/spp_detail_page.dart';

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
      builder: (context, state) => const Scaffold(body: Center(child: Text('Student Home'))), // Temporary
    ),
    /* // Uncomment setelah implement halaman terkait
    GoRoute(
      path: '/student/attendance',
      name: 'student-attendance',
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(
      path: '/student/attendance/scan',
      name: 'student-attendance-scan',
      builder: (context, state) => const ScanQrPage(),
    ),
    GoRoute(
      path: '/student/spp',
      name: 'student-spp',
      builder: (context, state) => const SppPage(),
    ),
    GoRoute(
      path: '/student/spp/detail/:bulan',
      name: 'student-spp-detail',
      builder: (context, state) {
        final bulan = state.pathParameters['bulan'] ?? '-';
        return SppDetailPage(bulan: bulan);
      },
    ),
    */
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
     // Uncomment setelah implement halaman terkait
    // GoRoute(
    //   path: '/profile',
    //   name: 'profile',
    //   builder: (context, state) => const ProfilePage(),
    // ),
    // GoRoute(
    //   path: '/profile/edit',
    //   name: 'profile-edit',
    //   builder: (context, state) => ProfileEditPage(
    //     isFromLogin: state.extra as bool? ?? false,
    //   ),
    // ),
    // GoRoute(
    //   path: '/profile/first-input',
    //   name: 'profile-first-input',
    //   builder: (context, state) => ProfileEditPage(
    //     isFromLogin: state.extra as bool? ?? false,
    //   ),
      
    // ),
    
  ];
}