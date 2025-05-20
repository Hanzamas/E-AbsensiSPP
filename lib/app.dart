import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
// import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'features/shared/auth/providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SecureStorage()),
        ),
      ],
      child: MaterialApp.router(
        title: 'E‑Absensi',
        debugShowCheckedModeBanner: false,
        // theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}