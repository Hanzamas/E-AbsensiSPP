// admin/akademik/pages/academic_teaching/edit_teaching_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/teaching_provider.dart';
import '../../data/models/teaching_model.dart';
import '../../../../shared/widgets/custom_loading_button.dart';
import '../../../users/widgets/custom_dropdown_field.dart';

class EditTeachingScreen extends StatefulWidget {
  final TeachingModel teaching;
  const EditTeachingScreen({Key? key, required this.teaching}) : super(key: key);

  @override
  _EditTeachingScreenState createState() => _EditTeachingScreenState();
}

class _EditTeachingScreenState extends State<EditTeachingScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedGuruId;
  int? _selectedMapelId;
  int? _selectedKelasId;
  String? _selectedHari;
  final _jamMulaiController = TextEditingController();
  final _jamSelesaiController = TextEditingController();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final List<String> _hariList = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];

  @override
  void initState() {
    super.initState();
    _selectedGuruId = widget.teaching.idGuru;
    _selectedMapelId = widget.teaching.idMapel;
    _selectedKelasId = widget.teaching.idKelas;
    _selectedHari = widget.teaching.hari;
    
    try {
      final startTimeParts = widget.teaching.jamMulai.split(':');
      _selectedStartTime = TimeOfDay(hour: int.parse(startTimeParts[0]), minute: int.parse(startTimeParts[1]));
      
      final endTimeParts = widget.teaching.jamSelesai.split(':');
      _selectedEndTime = TimeOfDay(hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1]));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           final localizations = MaterialLocalizations.of(context);
           _jamMulaiController.text = localizations.formatTimeOfDay(_selectedStartTime!, alwaysUse24HourFormat: true);
           _jamSelesaiController.text = localizations.formatTimeOfDay(_selectedEndTime!, alwaysUse24HourFormat: true);
        }
      });
    } catch (e) {
      print("Error parsing time on edit screen: $e");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeachingProvider>(context, listen: false).loadDependencies();
    });
  }

  // ... (dispose, _selectTime, _updateForm methods tidak berubah)
  @override
  void dispose() {
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    super.dispose();
  }
  
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime ?? TimeOfDay.now() : _selectedEndTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final localizations = MaterialLocalizations.of(context);
        final formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: true);
        if (isStartTime) {
          _selectedStartTime = picked;
          _jamMulaiController.text = formattedTime;
        } else {
          _selectedEndTime = picked;
          _jamSelesaiController.text = formattedTime;
        }
      });
    }
  }

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) { return; }
    
    if (_selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jam mulai dan selesai harus diisi'), backgroundColor: Colors.red));
      return;
    }

    final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jam selesai harus setelah jam mulai'), backgroundColor: Colors.red));
      return;
    }

    final provider = Provider.of<TeachingProvider>(context, listen: false);
    final payload = {
      "id_guru": _selectedGuruId,
      "id_mapel": _selectedMapelId,
      "id_kelas": _selectedKelasId,
      "hari": _selectedHari,
      "jam_mulai": "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00",
      "jam_selesai": "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00",
    };
    final success = await provider.updateTeaching(widget.teaching.id, payload);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: ${provider.error}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edit Pengajaran', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TeachingProvider>(
        builder: (context, provider, child) {
          final areDependenciesLoading = provider.isLoading && (provider.teachers.isEmpty || provider.subjects.isEmpty || provider.classes.isEmpty);
          if (areDependenciesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.teachers.isEmpty) {
            return Center(child: Text('Error memuat data: ${provider.error}'));
          }

          // ==== PERBAIKAN 1: Logika pengecekan guru ====
          final guruExists = provider.teachers.any((g) => g.id == _selectedGuruId);
          final mapelExists = provider.subjects.any((s) => s.id == _selectedMapelId);
          final kelasExists = provider.classes.any((c) => c.id == _selectedKelasId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CustomDropdownField(
                          value: guruExists ? _selectedGuruId?.toString() : null,
                          label: 'Guru',
                          icon: Icons.person_rounded,
                          items: provider.teachers.map((guru) {
                            // ==== PERBAIKAN 2: Nilai dropdown item ====
                            return DropdownMenuItem<String>(value: guru.id.toString(), child: Text(guru.namaLengkap));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedGuruId = int.tryParse(value ?? '')),
                          validator: (v) => v == null ? 'Guru harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField(
                          value: mapelExists ? _selectedMapelId?.toString() : null,
                          label: 'Mata Pelajaran',
                          icon: Icons.book_rounded,
                          items: provider.subjects.map((mapel) {
                            return DropdownMenuItem<String>(value: mapel.id.toString(), child: Text(mapel.nama));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedMapelId = int.tryParse(value ?? '')),
                           validator: (v) => v == null ? 'Mapel harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField(
                          value: kelasExists ? _selectedKelasId?.toString() : null,
                          label: 'Kelas',
                          icon: Icons.class_rounded,
                          items: provider.classes.map((kelas) {
                            return DropdownMenuItem<String>(value: kelas.id.toString(), child: Text(kelas.displayName));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedKelasId = int.tryParse(value ?? '')),
                           validator: (v) => v == null ? 'Kelas harus dipilih' : null,
                        ),
                         const SizedBox(height: 16),
                        CustomDropdownField(
                          value: _selectedHari,
                          label: 'Hari',
                          icon: Icons.calendar_today_rounded,
                          items: _hariList.map((hari) {
                            return DropdownMenuItem<String>(
                              value: hari,
                              child: Text(hari == 'jumat' ? 'Jum\'at' : hari.substring(0, 1).toUpperCase() + hari.substring(1)),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedHari = value),
                          validator: (v) => v == null ? 'Hari harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _jamMulaiController,
                          decoration: InputDecoration(
                             labelText: 'Jam Mulai',
                             prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFF2196F3)),
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, true),
                          validator: (v) => v!.isEmpty ? 'Jam mulai harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _jamSelesaiController,
                          decoration: InputDecoration(
                             labelText: 'Jam Selesai',
                             prefixIcon: const Icon(Icons.access_time_filled_rounded, color: Color(0xFF2196F3)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, false),
                           validator: (v) => v!.isEmpty ? 'Jam selesai harus diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomLoadingButton(
                    isLoading: provider.isLoading,
                    onPressed: _updateForm,
                    text: 'Simpan Perubahan',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}