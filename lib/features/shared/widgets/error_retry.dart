import 'package:flutter/material.dart';
import 'package:e_absensi/features/shared/animations/scale_animation.dart';

class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final Color iconColor;
  final Color buttonColor;
  final String retryText;
  final bool fullScreen;
  final Color? backgroundColor;
  final double iconSize;
  final double padding;

  const ErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.buttonColor = const Color(0xFF2196F3),
    this.retryText = 'Coba Lagi',
    this.fullScreen = false,
    this.backgroundColor,
    this.iconSize = 60.0,
    this.padding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Membersihkan pesan dari formatting HTML yang mungkin terbawa
    String cleanMessage = message.replaceAll(RegExp(r'<[^>]*>'), '');
    // Jika pesan terlalu panjang, batasi jumlah karakter
    if (cleanMessage.length > 150) {
      cleanMessage = '${cleanMessage.substring(0, 147)}...';
    }
    
    // Jika pesan berisi format exception atau syntax error, tampilkan pesan yang lebih ramah
    if (cleanMessage.contains('FormatException') || 
        cleanMessage.contains('SyntaxError') ||
        cleanMessage.contains('<!DOCTYPE')) {
      cleanMessage = 'Terjadi kesalahan saat memuat data dari server';
    }
    
    Widget content = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScaleAnimation(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            cleanMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _AnimatedRetryButton(
            onPressed: onRetry,
            text: retryText,
            color: buttonColor,
          ),
        ],
      ),
    );

    if (fullScreen) {
      return Container(
        color: backgroundColor ?? Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(child: content),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}

class _AnimatedRetryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const _AnimatedRetryButton({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  _AnimatedRetryButtonState createState() => _AnimatedRetryButtonState();
}

class _AnimatedRetryButtonState extends State<_AnimatedRetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onHover(true),
        onTapUp: (_) => _onHover(false),
        onTapCancel: () => _onHover(false),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? 10 : 6,
                  spreadRadius: _isHovered ? 1 : 0,
                  offset: Offset(0, _isHovered ? 3 : 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
