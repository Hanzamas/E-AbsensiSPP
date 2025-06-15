// widgets/custom_input_field.dart
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isRequired;
  final String? Function(String?)? customValidator;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.isPassword = false,
    this.isRequired = true,
    this.customValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: customValidator ?? (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}