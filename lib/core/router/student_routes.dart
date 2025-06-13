import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:e_absensi/features/student/dashboard/pages/student_dashboard_page.dart';
import 'package:e_absensi/features/student/attendance/pages/student_attendance_page.dart';
import 'package:e_absensi/features/student/attendance/pages/student_qr_scan_page.dart';
import 'package:e_absensi/features/student/attendance/pages/student_attendance_success_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_detail_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_barcode_page.dart';
import 'package:e_absensi/features/student/spp/pages/spp_verify_page.dart';
import 'package:e_absensi/core/utils/page_transition_helper.dart';
import 'package:e_absensi/features/student/spp/pages/student_spp_page.dart';

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
        child: const StudentAttendancePage(),
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance/scan',
      name: 'student-attendance-scan',
      pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
        child: const StudentQrScanPage(),
        type: TransitionType.slideUp,
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance/success',
      name: 'student-attendance-success',
      pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
        child: StudentAttendanceSuccessPage.fromExtra(context, state),
        type: TransitionType.scaleFade,
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/spp',
      name: 'student-spp',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const StudentSppPage(), // ✅ Use the new StudentSppPage
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
  ];
}