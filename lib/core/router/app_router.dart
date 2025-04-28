import 'package:flutter/material.dart';
import '../widgets/splash_screen.dart';
import '../../features/auth/presentation/login/login_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}