import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tipe-tipe transisi yang tersedia untuk digunakan
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

/// Helper class untuk membantu membuat transisi antar halaman
class PageTransitionHelper {
  /// Membuat halaman dengan transisi kustom menggunakan GoRouter
  static Page<dynamic> buildPageWithTransition({
    required Widget child,
    required TransitionType type,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    String? name,
    Object? arguments,
    String? restorationId,
    Alignment alignment = Alignment.center,
    LocalKey? key,
  }) {
    return CustomTransitionPage<dynamic>(
      key: key ?? ValueKey(name ?? child.runtimeType.toString()),
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        
        switch (type) {
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
                begin: 0.6,
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
      transitionDuration: duration,
    );
  }

  /// Membuat transisi slide dari kanan ke kiri
  static Page<dynamic> slideRightTransition({
    required Widget child,
    Curve curve = Curves.easeOutQuart,
    Duration duration = const Duration(milliseconds: 300),
    String? name,
    LocalKey? key,
  }) {
    return buildPageWithTransition(
      child: child,
      type: TransitionType.slideRight,
      curve: curve,
      duration: duration,
      name: name,
      key: key,
    );
  }

  /// Membuat transisi fade in
  static Page<dynamic> fadeTransition({
    required Widget child,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    String? name,
    LocalKey? key,
  }) {
    return buildPageWithTransition(
      child: child,
      type: TransitionType.fade,
      curve: curve,
      duration: duration,
      name: name,
      key: key,
    );
  }

  /// Membuat transisi scale dan fade
  static Page<dynamic> scaleFadeTransition({
    required Widget child,
    Curve curve = Curves.easeOutQuint,
    Duration duration = const Duration(milliseconds: 400),
    String? name,
    LocalKey? key,
    Alignment alignment = Alignment.center,
  }) {
    return buildPageWithTransition(
      child: child,
      type: TransitionType.scaleFade,
      curve: curve,
      duration: duration,
      name: name,
      key: key,
      alignment: alignment,
    );
  }

  /// Membuat transisi slide dari bawah
  static Page<dynamic> slideUpTransition({
    required Widget child,
    Curve curve = Curves.easeOutQuint,
    Duration duration = const Duration(milliseconds: 400),
    String? name,
    LocalKey? key,
  }) {
    return buildPageWithTransition(
      child: child,
      type: TransitionType.slideUp,
      curve: curve,
      duration: duration,
      name: name,
      key: key,
    );
  }
}
