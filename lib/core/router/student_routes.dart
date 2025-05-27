import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:e_absensi/features/student/dashboard/pages/home_page.dart';
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
      path: '/student/home',
      name: 'student-home',
      pageBuilder: (context, state) => PageTransitionHelper.fadeTransition(
        child: const StudentHomePage(),
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/student/attendance',
      name: 'student-attendance',
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AttendanceScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
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
    // GoRoute(
    //   path: '/student/attendance/success',
    //   name: 'student-attendance-success',
    //   pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
    //     child: AttendanceSuccess.fromExtra(context, state),
    //     type: TransitionType.scaleFade,
    //     curve: Curves.easeOutQuint,
    //     duration: const Duration(milliseconds: 500),
    //     key: state.pageKey,
    //   ),
    // ),
    // GoRoute(
    //   path: '/student/spp',
    //   name: 'student-spp',
    //   pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
    //     child: const SppPage(),
    //     type: TransitionType.slideLeft,
    //     duration: const Duration(milliseconds: 300),
    //     key: state.pageKey,
    //   ),
    // ),
    // GoRoute(
    //   path: '/student/spp/detail/:id',
    //   name: 'student-spp-detail',
    //   pageBuilder: (context, state) {
    //     final id = state.pathParameters['id'] ?? '0';
    //     return PageTransitionHelper.buildPageWithTransition(
    //       child: SppDetailPage(
    //         bulan: 'Pembayaran SPP id}',
    //         lunas: id == '1' || id == '2',
    //       ),
    //       type: TransitionType.slideLeft,
    //       duration: const Duration(milliseconds: 300),
    //       key: state.pageKey,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/student/spp/barcode',
    //   name: 'student-spp-barcode',
    //   pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
    //     child: const SppBarcodePage(bulan: 'Maret 2023'),
    //     type: TransitionType.scaleFade,
    //     duration: const Duration(milliseconds: 400),
    //     key: state.pageKey,
    //   ),
    // ),
    // GoRoute(
    //   path: '/student/spp/verify',
    //   name: 'student-spp-verify',
    //   pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
    //     child: const SppVerifyPage(),
    //     type: TransitionType.fade,
    //     duration: const Duration(milliseconds: 400),
    //     key: state.pageKey,
    //   ),
    // ),
  ];
} 