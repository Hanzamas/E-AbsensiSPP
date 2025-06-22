// admin/akademik/pages/academic_teaching/add_teaching_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import untuk jsonEncode
import '../../provider/teaching_provider.dart';
import '../../../../shared/widgets/custom_loading_button.dart';
import '../../../users/widgets/custom_dropdown_field.dart';

class AddTeachingScreen extends StatefulWidget {
  const AddTeachingScreen({Key? key}) : super(key: key);

  @override
  _AddTeachingScreenState createState() => _AddTeachingScreenState();
}

class _AddTeachingScreenState extends State<AddTeachingScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedGuruId;
  int? _selectedMapelId;
  int? _selectedKelasId;
  String? _selectedHari;
  final _jamMulaiController = TextEditingController();
  final _jamSelesaiController = TextEditingController();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final List<String> _hariList = [
    'senin',
    'selasa',
    'rabu',
    'kamis',
    'jumat',
    'sabtu',
    'minggu',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeachingProvider>(context, listen: false).loadDependencies();
    });
  }

  @override
  void dispose() {
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        final formattedTime = localizations.formatTimeOfDay(
          picked,
          alwaysUse24HourFormat: true,
        );
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

  // ================== FUNGSI DENGAN DEBUGGING ==================
  Future<void> _saveForm() async {
    print("--- [DEBUG] Tombol Simpan Ditekan ---");

    final isFormValid = _formKey.currentState?.validate() ?? false;
    print(
      "--- [DEBUG] Hasil validasi form (_formKey.currentState.validate()): $isFormValid ---",
    );

    if (!isFormValid) {
      print("--- [DEBUG] Form tidak valid. Proses dihentikan. ---");
      return;
    }

    print("--- [DEBUG] Nilai _selectedStartTime: $_selectedStartTime");
    print("--- [DEBUG] Nilai _selectedEndTime: $_selectedEndTime");

    if (_selectedStartTime == null || _selectedEndTime == null) {
      print(
        "--- [DEBUG] GAGAL: Validasi waktu null. Menampilkan SnackBar. ---",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam mulai dan Jam selesai wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("--- [DEBUG] LULUS: Validasi waktu null. ---");

    final startMinutes =
        _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;

    if (endMinutes <= startMinutes) {
      print(
        "--- [DEBUG] GAGAL: Validasi urutan waktu. Jam selesai tidak setelah jam mulai. ---",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus setelah jam mulai.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("--- [DEBUG] LULUS: Validasi urutan waktu. ---");

    final provider = Provider.of<TeachingProvider>(context, listen: false);

    final payload = {
      "id_guru": _selectedGuruId,
      "id_mapel": _selectedMapelId,
      "id_kelas": _selectedKelasId,
      "hari": _selectedHari,
      "jam_mulai":
          "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00",
      "jam_selesai":
          "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00",
    };

    print("--- [DEBUG] Payload yang akan dikirim: ${jsonEncode(payload)} ---");

    final success = await provider.createTeaching(payload);

    print("--- [DEBUG] Panggilan ke provider selesai. Hasil: $success ---");

    if (mounted) {
      if (success) {
        print("--- [DEBUG] Operasi SUKSES. Menutup halaman. ---");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajaran berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        print(
          "--- [DEBUG] Operasi GAGAL. Menampilkan error dari provider: ${provider.error} ---",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${provider.error ?? "Terjadi kesalahan"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ================== AKHIR FUNGSI DEBUGGING ==================

  @override
  Widget build(BuildContext context) {
    // Sisa dari build method tidak perlu diubah, biarkan sama seperti sebelumnya.
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Assign Guru ke Kelas', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TeachingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teachers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.teachers.isEmpty) {
            return Center(child: Text('Error memuat data: ${provider.error}'));
          }
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomDropdownField(
                          value: _selectedGuruId?.toString(),
                          label: 'Guru',
                          icon: Icons.person_rounded,
                          items:
                              provider.teachers.map((guru) {
                                return DropdownMenuItem<String>(
                                  // ==== PERBAIKAN DI SINI ====
                                  value: guru.id.toString(), // Menggunakan id (id_guru) bukan idUsers
                                  child: Text(guru.namaLengkap),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(
                                () =>
                                    _selectedGuruId = int.tryParse(value ?? ''),
                              ),
                          validator:
                              (v) => v == null ? 'Guru harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField(
                          value: _selectedMapelId?.toString(),
                          label: 'Mata Pelajaran',
                          icon: Icons.book_rounded,
                          items:
                              provider.subjects.map((mapel) {
                                return DropdownMenuItem<String>(
                                  value: mapel.id.toString(),
                                  child: Text(mapel.nama),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(
                                () =>
                                    _selectedMapelId = int.tryParse(
                                      value ?? '',
                                    ),
                              ),
                          validator:
                              (v) => v == null ? 'Mapel harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField(
                          value: _selectedKelasId?.toString(),
                          label: 'Kelas',
                          icon: Icons.class_rounded,
                          items:
                              provider.classes.map((kelas) {
                                return DropdownMenuItem<String>(
                                  value: kelas.id.toString(),
                                  child: Text(kelas.displayName),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(
                                () =>
                                    _selectedKelasId = int.tryParse(
                                      value ?? '',
                                    ),
                              ),
                          validator:
                              (v) => v == null ? 'Kelas harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdownField(
                          value: _selectedHari,
                          label: 'Hari',
                          icon: Icons.calendar_today_rounded,
                          items:
                              _hariList.map((hari) {
                                return DropdownMenuItem<String>(
                                  value: hari,
                                  child: Text(
                                    hari == 'jumat'
                                        ? 'Jum\'at'
                                        : hari.substring(0, 1).toUpperCase() +
                                            hari.substring(1),
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() => _selectedHari = value),
                          validator:
                              (v) => v == null ? 'Hari harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _jamMulaiController,
                          decoration: InputDecoration(
                            labelText: 'Jam Mulai',
                            prefixIcon: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF2196F3),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, true),
                          validator:
                              (v) =>
                                  v!.isEmpty ? 'Jam mulai harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _jamSelesaiController,
                          decoration: InputDecoration(
                            labelText: 'Jam Selesai',
                            prefixIcon: const Icon(
                              Icons.access_time_filled_rounded,
                              color: Color(0xFF2196F3),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, false),
                          validator:
                              (v) =>
                                  v!.isEmpty ? 'Jam selesai harus diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<TeachingProvider>(
                    builder: (context, provider, child) {
                      return CustomLoadingButton(
                        isLoading: provider.isLoading,
                        onPressed: _saveForm,
                        text: 'Simpan',
                      );
                    },
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