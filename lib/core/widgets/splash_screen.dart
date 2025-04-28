import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../constants/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context).textTheme;
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Judul bold
          Text(
            Strings.appName,
            style: theme.titleLarge?.copyWith(   // ganti dari headline5
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Logo
          Image.asset(
            Assets.logo,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              Strings.appDescription,
              textAlign: TextAlign.center,
              style: theme.bodyLarge,           // ganti dari subtitle1
            ),
          ),
        ],
      ),
    ),
  );
}
}