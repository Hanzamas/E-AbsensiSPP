import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/terms_and_condition.dart';
import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/register/register_page.dart';
import '../../features/auth/presentation/forgot_pass/forgotpass_page.dart';
import '../../features/auth/presentation/forgot_pass/otp_page.dart';
import '../../features/auth/presentation/forgot_pass/changepass_page.dart';
import '../../shared/transitions/fade_transition.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (ctx, state) =>
            MaterialPage(child: const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const OtpPage(),
        ),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ChangePasswordPage(),
        ),
      ),
      GoRoute(
        path: '/terms-login',
        name: 'terms-login',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const TermsAndConditionsPage(source: 'login'),
        ),
      ),
      GoRoute(
        path: '/terms-register',
        name: 'terms-register',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const TermsAndConditionsPage(source: 'register'),
        ),
      ),
    ],
  );
}