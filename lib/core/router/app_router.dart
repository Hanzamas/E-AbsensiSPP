import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login/login_page.dart';
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
    ],
  );
}