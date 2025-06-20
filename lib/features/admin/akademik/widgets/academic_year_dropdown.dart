import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/class_provider.dart';

class AcademicYearDropdown extends StatelessWidget {
  final int? selectedValue;
  final void Function(int?) onChanged;
  final String? Function(int?)? validator;

  const AcademicYearDropdown({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (context, provider, child) {
        // Tampilkan loading jika data tahun ajaran sedang dimuat
        if (provider.isLoading && provider.academicYears.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Tampilkan pesan error jika gagal memuat
        if (provider.error != null && provider.academicYears.isEmpty) {
          return Text("Gagal memuat tahun ajaran: ${provider.error}");
        }

        return DropdownButtonFormField<int>(
          value: selectedValue,
          decoration: InputDecoration(
            labelText: 'Tahun Ajaran',
            prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2196F3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          hint: const Text('Pilih Tahun Ajaran'),
          items: provider.academicYears.map((year) {
            return DropdownMenuItem<int>(
              value: year.id,
              child: Text(year.nama), // Menampilkan "2024/2025", etc.
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator ?? (value) {
            if (value == null) {
              return 'Tahun ajaran harus dipilih';
            }
            return null;
          },
        );
      },
    );
  }
}