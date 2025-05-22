import 'package:flutter/material.dart';

enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double offset;
  final Curve curve;

  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.direction = SlideDirection.fromBottom,
    this.offset = 100.0,
    this.curve = Curves.easeOutQuart,
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Set start and end offset based on slide direction
    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.fromTop:
        beginOffset = Offset(0, -widget.offset / 100);
        break;
      case SlideDirection.fromBottom:
        beginOffset = Offset(0, widget.offset / 100);
        break;
      case SlideDirection.fromLeft:
        beginOffset = Offset(-widget.offset / 100, 0);
        break;
      case SlideDirection.fromRight:
        beginOffset = Offset(widget.offset / 100, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
} 