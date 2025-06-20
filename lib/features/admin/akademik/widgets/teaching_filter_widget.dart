import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../users/widgets/custom_dropdown_field.dart';
import '../provider/teaching_provider.dart';

class TeachingFilterWidget extends StatefulWidget {
  const TeachingFilterWidget({Key? key}) : super(key: key);

  @override
  State<TeachingFilterWidget> createState() => _TeachingFilterWidgetState();
}

class _TeachingFilterWidgetState extends State<TeachingFilterWidget> {
  bool _isExpanded = false;

  // Variabel lokal untuk menampung pilihan sementara di dalam widget
  int? _tempGuruId;
  int? _tempMapelId;
  int? _tempKelasId;

  @override
  void initState() {
    super.initState();
    // Saat widget pertama kali dibuat, sinkronkan state lokal dengan provider
    final provider = Provider.of<TeachingProvider>(context, listen: false);
    _tempGuruId = provider.selectedFilterGuruId;
    _tempMapelId = provider.selectedFilterMapelId;
    _tempKelasId = provider.selectedFilterKelasId;
  }
  
  void _applyFilters() {
    final provider = Provider.of<TeachingProvider>(context, listen: false);
    provider.applyFilters(
      guruId: _tempGuruId,
      mapelId: _tempMapelId,
      kelasId: _tempKelasId,
    );
  }

  void _clearFilters() {
    final provider = Provider.of<TeachingProvider>(context, listen: false);
    provider.clearFilters();
    setState(() {
      _tempGuruId = null;
      _tempMapelId = null;
      _tempKelasId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Watch untuk mendengarkan perubahan pada provider
    final provider = context.watch<TeachingProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Filter Daftar Pengajaran', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: Badge(
              label: Text(provider.isFilterActive ? '!' : '0'),
              isLabelVisible: provider.isFilterActive,
              child: const Icon(Icons.filter_list, color: Color(0xFF2196F3)),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  CustomDropdownField(
                    value: _tempGuruId?.toString(),
                    label: 'Filter by Guru',
                    icon: Icons.person_search_rounded,
                    items: provider.teachers.map((guru) {
                      return DropdownMenuItem<String>(value: guru.id.toString(), child: Text(guru.namaLengkap));
                    }).toList(),
                    onChanged: (value) => setState(() => _tempGuruId = int.tryParse(value ?? '')),
                    validator: null, // Validator tidak wajib di sini
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField(
                    value: _tempMapelId?.toString(),
                    label: 'Filter by Mapel',
                    icon: Icons.book_rounded,
                    items: provider.subjects.map((mapel) {
                      return DropdownMenuItem<String>(value: mapel.id.toString(), child: Text(mapel.nama));
                    }).toList(),
                    onChanged: (value) => setState(() => _tempMapelId = int.tryParse(value ?? '')),
                    validator: null,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdownField(
                    value: _tempKelasId?.toString(),
                    label: 'Filter by Kelas',
                    icon: Icons.class_rounded,
                    items: provider.classes.map((kelas) {
                      return DropdownMenuItem<String>(value: kelas.id.toString(), child: Text(kelas.displayName));
                    }).toList(),
                    onChanged: (value) => setState(() => _tempKelasId = int.tryParse(value ?? '')),
                    validator: null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Reset Filter'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text('Terapkan'),
                          style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF2196F3),
                             foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}