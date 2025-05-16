import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(AuthRepository(AuthService())),
      child: MaterialApp.router(
        title: 'E‑AbsensiSPP',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}