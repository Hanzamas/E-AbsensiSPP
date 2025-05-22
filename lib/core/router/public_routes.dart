import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:e_absensi/features/shared/auth/pages/splash/splash_screen.dart';
import 'package:e_absensi/features/shared/auth/pages/login/login_page.dart';
import 'package:e_absensi/features/shared/auth/pages/register/register_page.dart';
import 'package:e_absensi/features/shared/auth/pages/terms/terms_and_condition.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/forgotpass_page.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/otp_page.dart';
import 'package:e_absensi/features/shared/auth/pages/forgot_pass/changepass_page.dart';
import 'package:e_absensi/core/utils/page_transition_helper.dart';

class PublicRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => PageTransitionHelper.fadeTransition(
        child: const LoginPage(),
        duration: const Duration(milliseconds: 800),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const RegisterPage(),
        curve: Curves.easeOutQuart,
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      pageBuilder: (context, state) => PageTransitionHelper.scaleFadeTransition(
        child: TermsAndConditionsPage(
          source: state.extra as String? ?? 'login',
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      pageBuilder: (context, state) => PageTransitionHelper.slideUpTransition(
        child: const ForgotPasswordPage(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: OtpPage(
          email: state.extra as String,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: ChangePasswordPage(
          email: state.extra as String,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        key: state.pageKey,
      ),
    ),
  ];
} 