// admin/akademik/pages/teaching/add_teaching_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import untuk jsonEncode
import '../../provider/teaching_provider.dart';
import '../../../../shared/widgets/custom_loading_button.dart';
import '../../../users/widgets/custom_dropdown_field.dart';

// Import model yang diperlukan untuk proses de-duplikasi
import '../../data/models/class_model.dart';
import '../../data/models/subject_model.dart';
import '../../../users/data/models/teacher_model.dart';
import 'package:flutter/foundation.dart';

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
        if (isStartTime) {
          _selectedStartTime = picked;
          // Format waktu ke HH:mm
          _jamMulaiController.text = 
              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        } else {
          _selectedEndTime = picked;
          // Format waktu ke HH:mm
          _jamSelesaiController.text = 
              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        }
      });
    }
  }

  // FUNGSI DEBUG UNTUK MEMERIKSA DATA SEBELUM DIKIRIM
  void _debugPrintData() {
    print("=== DEBUG DATA SEBELUM KIRIM ===");
    print("Selected Guru ID: $_selectedGuruId");
    print("Selected Mapel ID: $_selectedMapelId");
    print("Selected Kelas ID: $_selectedKelasId");
    print("Selected Hari: $_selectedHari");
    print("Jam Mulai Controller: ${_jamMulaiController.text}");
    print("Jam Selesai Controller: ${_jamSelesaiController.text}");
    print("Selected Start Time: $_selectedStartTime");
    print("Selected End Time: $_selectedEndTime");
    print("==============================");
  }

  Future<void> _saveForm() async {
    // DEBUG: Print semua data sebelum validasi
    _debugPrintData();

    // 1. Validasi dasar dari form
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      print("Form validation failed");
      return;
    }

    // 2. Validasi manual yang lebih detail
    final validationErrors = <String>[];
    
    if (_selectedGuruId == null) {
      validationErrors.add('Guru belum dipilih');
    }
    if (_selectedMapelId == null) {
      validationErrors.add('Mata Pelajaran belum dipilih');
    }
    if (_selectedKelasId == null) {
      validationErrors.add('Kelas belum dipilih');
    }
    if (_selectedHari == null || _selectedHari!.isEmpty) {
      validationErrors.add('Hari belum dipilih');
    }
    if (_selectedStartTime == null) {
      validationErrors.add('Jam Mulai belum dipilih');
    }
    if (_selectedEndTime == null) {
      validationErrors.add('Jam Selesai belum dipilih');
    }

    // Jika ada error validasi, tampilkan dan hentikan
    if (validationErrors.isNotEmpty) {
      final errorMessage = validationErrors.join('\n• ');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validasi gagal:\n• $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 3. Validasi urutan waktu
    final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;

    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jam selesai harus setelah jam mulai.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 4. Buat payload dengan format yang benar
    final payload = {
      "id_guru": _selectedGuruId,
      "id_mapel": _selectedMapelId,
      "id_kelas": _selectedKelasId,
      "hari": _selectedHari,
      "jam_mulai": "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00",
      "jam_selesai": "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00",
    };

    // DEBUG: Print payload yang akan dikirim
    print("=== PAYLOAD YANG AKAN DIKIRIM ===");
    print(jsonEncode(payload));
    print("================================");

    final provider = Provider.of<TeachingProvider>(context, listen: false);
    final success = await provider.createTeaching(payload);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajaran berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        // Tampilkan error yang lebih detail
        final errorMessage = provider.error ?? "Terjadi kesalahan tidak diketahui";
        print("Error dari server: $errorMessage");
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan pengajaran:\n$errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Assign Guru ke Kelas'),
        backgroundColor: const Color(0xFF2196F3),
        // Tambahkan debug button di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugPrintData,
            tooltip: 'Debug Data',
          ),
        ],
      ),
      body: Consumer<TeachingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teachers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.teachers.isEmpty) {
            return Center(child: Text('Error memuat data: ${provider.error}'));
          }

          // Hapus duplikat data
          final uniqueTeachers = <Teacher>[];
          final seenTeacherIds = <int>{};
          for (final guru in provider.teachers) {
            if (seenTeacherIds.add(guru.id)) {
              uniqueTeachers.add(guru);
            }
          }

          final uniqueSubjects = <SubjectModel>[];
          final seenSubjectIds = <int?>{};
          for (final mapel in provider.subjects) {
            if (mapel.id != null && seenSubjectIds.add(mapel.id)) {
              uniqueSubjects.add(mapel);
            }
          }

          final uniqueClasses = <ClassModel>[];
          final seenClassIds = <int>{};
          for (final kelas in provider.classes) {
            if (seenClassIds.add(kelas.id)) {
              uniqueClasses.add(kelas);
            }
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
                        // Guru Dropdown
                        CustomDropdownField(
                          value: _selectedGuruId?.toString(),
                          label: 'Guru',
                          icon: Icons.person_rounded,
                          items: uniqueTeachers.map((guru) {
                            return DropdownMenuItem<String>(
                              value: guru.id.toString(),
                              child: Text(guru.namaLengkap),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGuruId = int.tryParse(value ?? '');
                            });
                            print("Guru selected: $_selectedGuruId");
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Guru harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Mapel Dropdown
                        CustomDropdownField(
                          value: _selectedMapelId?.toString(),
                          label: 'Mata Pelajaran',
                          icon: Icons.book_rounded,
                          items: uniqueSubjects.map((mapel) {
                            return DropdownMenuItem<String>(
                              value: mapel.id.toString(),
                              child: Text(mapel.nama),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMapelId = int.tryParse(value ?? '');
                            });
                            print("Mapel selected: $_selectedMapelId");
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Mata Pelajaran harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Kelas Dropdown
                        CustomDropdownField(
                          value: _selectedKelasId?.toString(),
                          label: 'Kelas',
                          icon: Icons.class_rounded,
                          items: uniqueClasses.map((kelas) {
                            return DropdownMenuItem<String>(
                              value: kelas.id.toString(),
                              child: Text(kelas.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKelasId = int.tryParse(value ?? '');
                            });
                            print("Kelas selected: $_selectedKelasId");
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Kelas harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Hari Dropdown
                        CustomDropdownField(
                          value: _selectedHari,
                          label: 'Hari',
                          icon: Icons.calendar_today_rounded,
                          items: _hariList.map((hari) {
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
                          onChanged: (value) {
                            setState(() {
                              _selectedHari = value;
                            });
                            print("Hari selected: $_selectedHari");
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Hari harus dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Jam Mulai
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
                            suffixIcon: _selectedStartTime != null 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, true),
                          validator: (v) => v == null || v.isEmpty ? 'Jam mulai harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Jam Selesai
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
                            suffixIcon: _selectedEndTime != null 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context, false),
                          validator: (v) => v == null || v.isEmpty ? 'Jam selesai harus diisi' : null,
                        ),
                        
                        // Debug info (untuk development)
                        if (kDebugMode) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Guru ID: $_selectedGuruId'),
                                Text('Mapel ID: $_selectedMapelId'),
                                Text('Kelas ID: $_selectedKelasId'),
                                Text('Hari: $_selectedHari'),
                                Text('Start Time: $_selectedStartTime'),
                                Text('End Time: $_selectedEndTime'),
                              ],
                            ),
                          ),
                        ],
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