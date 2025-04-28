import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E‑AbsensiSPP',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}