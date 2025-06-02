import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/core/constants/app_strings.dart';
import 'package:e_absensi/core/constants/assets.dart';
import 'package:e_absensi/features/shared/animations/fade_in_animation.dart';
import 'package:e_absensi/features/shared/auth/provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Minimum splash duration
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final role = await authProvider.checkAuth();

      if (!mounted) return;

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (role != null && authProvider.isAuthenticated) {
        // ✅ Navigate based on stored role (already normalized)
        debugPrint('🎯 Splash: Authenticated user with role: $role');
        
        switch (role) { // ✅ Match normalized role format
          case 'siswa':
            context.go('/student/home');
            break;
          case 'guru':
            context.go('/teacher/home');
            break;
          case 'admin':
            context.go('/admin/home');
            break;
          default:
            debugPrint('❌ Unknown role: $role, redirecting to login');
            context.goNamed('login');
        }
      } else {
        debugPrint('🔍 Splash: No auth found, redirecting to login');
        context.goNamed('login');
      }
    } catch (e) {
      debugPrint('❌ Splash: Error during auth check - $e');
      if (!mounted) return;
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Color(0xFF2196F3), Color(0xFF64B5F6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dengan animasi
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: Image.asset(
                        Assets.logo,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // App Name
              FadeInAnimation(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // App Description
              FadeInAnimation(
                duration: const Duration(milliseconds: 1200),
                offset: 30,
                child: Text(
                  AppStrings.appDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading Indicator
              const FadeInAnimation(
                duration: Duration(milliseconds: 1500),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}