import 'package:flutter/material.dart';

// Transisi fade untuk halaman baru
class FadeTransitionPage extends Page {
  final Widget child;
  final Duration duration;

  const FadeTransitionPage({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// Transisi slide dari bawah ke atas
class SlideUpTransitionPage extends Page {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SlideUpTransitionPage({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// Transisi slide dari kanan ke kiri (default)
class SlideRightTransitionPage extends Page {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SlideRightTransitionPage({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// Transisi scale dan fade
class ScaleFadeTransitionPage extends Page {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const ScaleFadeTransitionPage({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutQuart,
    this.alignment = Alignment.center,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            alignment: alignment,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}

// Custom page route builder dengan transisi yang bisa digunakan dengan GoRouter
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            
            switch (transitionType) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                );
              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.slideDown:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  alignment: alignment,
                  child: child,
                );
              case TransitionType.scaleFade:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.6,
                      end: 1.0,
                    ).animate(curvedAnimation),
                    alignment: alignment,
                    child: child,
                  ),
                );
              case TransitionType.rotation:
                return RotationTransition(
                  turns: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              default:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                );
            }
          },
        );
}

enum TransitionType {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  scaleFade,
  rotation,
} 