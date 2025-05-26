import 'package:flutter/material.dart';
import 'package:e_absensi/features/shared/animations/pulse_animation.dart';

class DefaultLoading extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;
  final String? message;
  final TextStyle? textStyle;
  final bool fullScreen;
  final Color? backgroundColor;

  const DefaultLoading({
    super.key,
    this.color = Colors.blue,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.message,
    this.textStyle,
    this.fullScreen = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PulseAnimation(
          minScale: 0.9,
          maxScale: 1.1,
          duration: const Duration(milliseconds: 1200),
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: textStyle ?? 
                TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Container(
        color: backgroundColor ?? Colors.white.withOpacity(0.9),
        width: double.infinity,
        height: double.infinity,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class SpinningLogoLoading extends StatelessWidget {
  final String logoAsset;
  final double size;
  final String? message;
  final TextStyle? textStyle;
  final bool fullScreen;
  final Color? backgroundColor;

  const SpinningLogoLoading({
    super.key,
    required this.logoAsset,
    this.size = 70.0,
    this.message,
    this.textStyle,
    this.fullScreen = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpinningLogo(logo: logoAsset, size: size),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: textStyle ?? 
                const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Container(
        color: backgroundColor ?? Colors.white.withOpacity(0.9),
        width: double.infinity,
        height: double.infinity,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class _SpinningLogo extends StatefulWidget {
  final String logo;
  final double size;

  const _SpinningLogo({
    required this.logo,
    required this.size,
  });

  @override
  _SpinningLogoState createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<_SpinningLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.asset(
          widget.logo,
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
