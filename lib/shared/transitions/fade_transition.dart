import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeIn,
  }) : super(
          key: key,
          child: child,
          transitionDuration: duration,
          transitionsBuilder: (context, anim, _, child) {
            final fade = CurvedAnimation(parent: anim, curve: curve);
            return FadeTransition(opacity: fade, child: child);
          },
        );
}