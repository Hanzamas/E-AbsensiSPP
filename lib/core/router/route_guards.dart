// core/router/route_guards.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';

class RouteGuards {
  static final _storage = SecureStorage();

  // Redirect berdasarkan auth state
  static Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final token = await _storage.getToken();
    
    // List route yang tidak perlu auth
    final publicRoutes = [
      '/splash',
      '/login',
      '/register',
      '/forgot-password',
      '/otp-verification',
      '/change-password',
      '/terms-login',
      '/terms-register',
    ];

    // Jika di public route dan sudah login, redirect ke home
    if (publicRoutes.contains(state.uri.path) && token != null) {
      final role = await _storage.getUserRole();
      return _getHomeRoute(role);
    }

    // Jika di protected route dan belum login, redirect ke login
    if (!publicRoutes.contains(state.uri.path) && token == null) {
      return '/login';
    }

    return null;
  }

  // Redirect berdasarkan role
  static Future<String?> roleGuard(BuildContext context, GoRouterState state) async {
    final role = await _storage.getUserRole();
    final currentPath = state.uri.path;

    // Cek akses berdasarkan prefix path
    if (currentPath.startsWith('/student') && role != 'student' ||
        currentPath.startsWith('/teacher') && role != 'teacher' ||
        currentPath.startsWith('/admin') && role != 'admin') {
      return _getHomeRoute(role);
    }

    return null;
  }

  // Helper untuk mendapatkan home route berdasarkan role
  static String _getHomeRoute(String? role) {
    switch (role) {
      case 'siswa':
        return '/student/home';
      case 'guru':
        return '/teacher/home';
      case 'admin':
        return '/admin/home';
      default:
        return '/login';
    }
  }
}