import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:e_absensi/features/student/dashboard/pages/student_dashboard_page.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_screen.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_scan.dart';
import 'package:e_absensi/features/student/attendance/pages/attendance_success.dart';
import 'package:e_absensi/features/student/spp/pages/spp_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_detail_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_barcode_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_verify_page.dart';
import 'package:e_absensi/core/utils/page_transition_helper.dart';

class StudentRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: '/student/home', // ✅ Change path to match existing navigation
      name: 'student-home',
      pageBuilder: (context, state) => PageTransitionHelper.fadeTransition(
        child: const StudentDashboardPage(), // ✅ Make sure this matches existing HomePage
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance',
      name: 'student-attendance',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const AttendanceScreen(),
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance/scan',
      name: 'student-attendance-scan',
      pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
        child: const AttendanceQr(),
        type: TransitionType.slideUp,
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance/success',
      name: 'student-attendance-success',
      pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
        child: AttendanceSuccess.fromExtra(context, state),
        type: TransitionType.scaleFade,
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
  ];
}