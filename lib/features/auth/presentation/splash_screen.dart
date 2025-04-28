import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Strings.appName,
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Image.asset(
                Assets.logo,
                width: 240,
                height: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  Strings.appDescription,
                  textAlign: TextAlign.center,
                  style: t.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}