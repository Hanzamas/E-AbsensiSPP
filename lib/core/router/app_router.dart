// core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'route_guards.dart';
import 'public_routes.dart';
import 'student_routes.dart';
import 'teacher_routes.dart';
import 'admin_routes.dart';
import 'shared_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: RouteGuards.authGuard,
    routes: [
      ...PublicRoutes.routes,
      ...StudentRoutes.routes,
      ...TeacherRoutes.routes,
      ...AdminRoutes.routes,
      ...SharedRoutes.routes,
    ],
  );
}