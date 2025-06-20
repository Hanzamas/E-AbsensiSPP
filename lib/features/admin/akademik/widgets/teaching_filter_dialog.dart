import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../users/widgets/custom_dropdown_field.dart';
import '../provider/teaching_provider.dart';

class TeachingFilterDialog extends StatefulWidget {
  const TeachingFilterDialog({Key? key}) : super(key: key);

  @override
  _TeachingFilterDialogState createState() => _TeachingFilterDialogState();
}

class _TeachingFilterDialogState extends State<TeachingFilterDialog> {
  int? _guruId;
  int? _mapelId;
  int? _kelasId;

  @override
  void initState() {
    super.initState();
    // Ambil nilai filter yang sedang aktif dari provider
    final provider = Provider.of<TeachingProvider>(context, listen: false);
    _guruId = provider.selectedFilterGuruId;
    _mapelId = provider.selectedFilterMapelId;
    _kelasId = provider.selectedFilterKelasId;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeachingProvider>();

    return AlertDialog(
      title: const Text('Filter Pengajaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdownField(
              value: _guruId?.toString(),
              label: 'Filter by Guru',
              icon: Icons.person_search_rounded,
              items: provider.teachers.map((guru) {
                return DropdownMenuItem<String>(
                  value: guru.idUsers.toString(),
                  child: Text(guru.namaLengkap),
                );
              }).toList(),
              onChanged: (value) => setState(() => _guruId = int.tryParse(value ?? '')),
            ),
            const SizedBox(height: 16),
            CustomDropdownField(
              value: _mapelId?.toString(),
              label: 'Filter by Mapel',
              icon: Icons.book_rounded,
              items: provider.subjects.map((mapel) {
                return DropdownMenuItem<String>(
                  value: mapel.id.toString(),
                  child: Text(mapel.nama),
                );
              }).toList(),
              onChanged: (value) => setState(() => _mapelId = int.tryParse(value ?? '')),
            ),
            const SizedBox(height: 16),
            CustomDropdownField(
              value: _kelasId?.toString(),
              label: 'Filter by Kelas',
              icon: Icons.class_rounded,
              items: provider.classes.map((kelas) {
                return DropdownMenuItem<String>(
                  value: kelas.id.toString(),
                  child: Text(kelas.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _kelasId = int.tryParse(value ?? '')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset filter dan tutup dialog
            provider.clearFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            // Terapkan filter dan tutup dialog
            provider.applyFilters(
              guruId: _guruId,
              mapelId: _mapelId,
              kelasId: _kelasId,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Terapkan'),
        ),
      ],
    );
  }
}