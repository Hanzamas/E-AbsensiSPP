import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/core/storage/secure_storage.dart';

class RouteGuards {
  static final _storage = SecureStorage();

  static Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final token = await _storage.read('token');
    final role = await _storage.read('user_role');
    
    final publicRoutes = ['/splash', '/login', '/register', '/forgot-password', '/otp-verification', '/change-password', '/terms'];
    final currentPath = state.matchedLocation;

    // If accessing public routes and already authenticated, redirect to home
    if (publicRoutes.contains(currentPath) && token != null && role != null) {
      return getHomeRoute(role);
    }

    // If accessing protected routes and not authenticated, redirect to login
    if (!publicRoutes.contains(currentPath) && token == null) {
      return '/login';
    }

    // ✅ Role-based access control
    if (currentPath.startsWith('/student') && role != 'siswa') {
      return getHomeRoute(role);
    }
    if (currentPath.startsWith('/teacher') && role != 'guru') {
      return getHomeRoute(role);
    }
    if (currentPath.startsWith('/admin') && role != 'admin') {
      return getHomeRoute(role);
    }

    return null;
  }
  
  static String getHomeRoute(String? role) {
    switch (role?.toLowerCase()) {
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

// ✅ Helper function for other files
String getHomeRoute(String? role) => RouteGuards.getHomeRoute(role);