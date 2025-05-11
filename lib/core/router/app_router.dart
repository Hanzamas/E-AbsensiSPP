import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/terms_and_condition.dart';
import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/register/register_page.dart';
import '../../features/auth/presentation/forgot_pass/forgotpass_page.dart';
import '../../features/auth/presentation/forgot_pass/otp_page.dart';
import '../../features/auth/presentation/forgot_pass/changepass_page.dart';
import '../../shared/transitions/fade_transition.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/home/presentation/student_home_page.dart';
import '../../features/profile/presentation/profile_success_page.dart';
import '../../features/profile/presentation/profile_main_page.dart';
import '../../features/profile/presentation/profile_edit_page.dart';

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
          child: BlocProvider(
            create: (context) {
              final authService = AuthService();
              final authRepository = AuthRepository(authService);
              return AuthCubit(authRepository);
            },
            child: const LoginPage(),
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) {
              final authService = AuthService();
              final authRepository = AuthRepository(authService);
              return AuthCubit(authRepository);
            },
            child: const RegisterPage(),
          ),
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
      GoRoute(
        path: '/student/home',
        name: 'student-home',
        pageBuilder: (ctx, state) {
          final fullname = state.extra as String? ?? '';
          return MaterialPage(
            child: StudentHomePage(fullname: fullname),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ProfileMainPage(),
        ),
      ),
      GoRoute(
        path: '/profile-edit',
        name: 'profile-edit',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ProfileEditPage(),
        ),
      ),
      GoRoute(
        path: '/profile-success',
        name: 'profile-success',
        pageBuilder: (ctx, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ProfileSuccessPage(),
        ),
      ),
    ],
  );
}