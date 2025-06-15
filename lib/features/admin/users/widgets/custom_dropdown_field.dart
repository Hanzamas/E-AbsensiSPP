// widgets/custom_dropdown_field.dart
import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownField({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator ?? (value) =>
          (value == null || value.isEmpty)
              ? '$label tidak boleh kosong'
              : null,
    );
  }
}