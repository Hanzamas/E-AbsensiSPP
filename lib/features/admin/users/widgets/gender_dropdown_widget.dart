// widgets/gender_dropdown_widget.dart
import 'package:flutter/material.dart';
import 'custom_dropdown_field.dart';

class GenderDropdownWidget extends StatelessWidget {
  final String? selectedGender;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const GenderDropdownWidget({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropdownField(
      value: selectedGender,
      label: 'Jenis Kelamin',
      icon: Icons.wc,
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}