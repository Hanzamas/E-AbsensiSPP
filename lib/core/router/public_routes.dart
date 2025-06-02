import 'package:go_router/go_router.dart';
import '../../features/shared/auth/pages/splash/splash_screen.dart';
import '../../features/shared/auth/pages/login/login_page.dart';
import '../../features/shared/auth/pages/register/register_page.dart';
import '../../features/shared/auth/pages/forgot_pass/forgotpass_page.dart';
import '../../features/shared/auth/pages/forgot_pass/otp_page.dart';
import '../../features/shared/auth/pages/forgot_pass/changepass_page.dart';
import '../../features/shared/auth/pages/terms/terms_and_condition.dart';

class PublicRoutes {
  static final List<RouteBase> routes = [
    // ✅ Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ✅ Auth Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) => OtpPage(
        email: state.extra as String,
      ),
    ),
    
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => ChangePasswordPage(
        email: state.extra as String,
      ),
    ),
    
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => TermsAndConditionsPage(
        source: state.extra as String? ?? 'login',
      ),
    ),
  ];
}