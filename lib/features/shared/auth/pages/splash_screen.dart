// lib/features/shared/auth/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/assets.dart';
import '../../../../shared/animations/fade_in_animation.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final role = await authProvider.checkAuth();

    if (!mounted) return;

    if (role != null) {
      switch (role) {
        case 'student':
          context.goNamed('student-home');
          break;
        case 'teacher':
          context.goNamed('teacher-home');
          break;
        case 'admin':
          context.goNamed('admin-home');
          break;
        default:
          context.goNamed('login');
      }
    } else {
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeInAnimation(
          duration: const Duration(milliseconds: 1500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.logo,
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 16),
              Text(
                Strings.appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}