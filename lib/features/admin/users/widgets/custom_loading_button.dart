// widgets/custom_loading_button.dart
import 'package:flutter/material.dart';

class CustomLoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomLoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.backgroundColor = const Color(0xFF2196F3),
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}