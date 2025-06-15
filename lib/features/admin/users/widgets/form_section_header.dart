// widgets/form_section_header.dart
import 'package:flutter/material.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const FormSectionHeader({
    Key? key,
    required this.title,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.black,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}