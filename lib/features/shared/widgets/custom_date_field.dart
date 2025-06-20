// widgets/custom_date_field.dart
import 'package:flutter/material.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const CustomDateField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2196F3),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      readOnly: true,
      onTap: onTap,
      validator: validator ?? (value) =>
          (value == null || value.isEmpty)
              ? '$label tidak boleh kosong'
              : null,
    );
  }
}