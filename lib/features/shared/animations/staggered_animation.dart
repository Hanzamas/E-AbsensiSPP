import 'package:flutter/material.dart';

class StaggeredAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool fadeIn;
  final bool scaleIn;
  final bool slideIn;
  final SlideDirection slideDirection;
  final double slideOffset;
  final double beginScale;
  final Curve curve;

  const StaggeredAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.fadeIn = true,
    this.scaleIn = true,
    this.slideIn = true,
    this.slideDirection = SlideDirection.fromBottom,
    this.slideOffset = 50.0,
    this.beginScale = 0.8,
    this.curve = Curves.easeOutQuint,
  });

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(curve);

    // Set start and end offset based on slide direction
    Offset beginOffset;
    switch (widget.slideDirection) {
      case SlideDirection.fromTop:
        beginOffset = Offset(0, -widget.slideOffset / 100);
        break;
      case SlideDirection.fromBottom:
        beginOffset = Offset(0, widget.slideOffset / 100);
        break;
      case SlideDirection.fromLeft:
        beginOffset = Offset(-widget.slideOffset / 100, 0);
        break;
      case SlideDirection.fromRight:
        beginOffset = Offset(widget.slideOffset / 100, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.fadeIn) {
      child = FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      );
    }

    if (widget.scaleIn) {
      child = ScaleTransition(
        scale: _scaleAnimation,
        child: child,
      );
    }

    if (widget.slideIn) {
      child = SlideTransition(
        position: _slideAnimation,
        child: child,
      );
    }

    return child;
  }
} 