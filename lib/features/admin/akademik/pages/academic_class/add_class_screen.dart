import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/class_model.dart';
import '../../provider/class_provider.dart';
import '../../widgets/academic_year_dropdown.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_loading_button.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({Key? key}) : super(key: key);

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kapasitasController = TextEditingController();
  // --- HAPUS TEXT CONTROLLER TAHUN AJARAN ---
  // final _tahunAjaranController = TextEditingController(); 
  
  // --- TAMBAHKAN STATE UNTUK NILAI DROPDOWN ---
  int? _selectedTahunAjaranId;
  @override
  void initState() {
    super.initState();
    // Panggil provider untuk memuat data tahun ajaran saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).fetchAcademicYears();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedTahunAjaranId != null) {
      final newClass = ClassModel(
        id: 0,
        namaKelas: _namaController.text,
        kapasitas: int.parse(_kapasitasController.text),
        idTahunAjaran: _selectedTahunAjaranId!,
        tahunAjaran: '', 
      );

      final provider = Provider.of<ClassProvider>(context, listen: false);
      final success = await provider.createClass(newClass);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kelas berhasil ditambahkan'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${provider.error ?? "Gagal"}'), backgroundColor: Colors.red),
          );
        }
      }
    } else if (_selectedTahunAjaranId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahun Ajaran wajib dipilih'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tambah Kelas'),
        backgroundColor: const Color(0xFF2196F3),
        // ... (UI AppBar lainnya tidak berubah)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4),) ],
                    ),
                    child: Column(
                      children: [
                        CustomInputField(
                    controller: _namaController,
                    label: 'Nama Kelas',
                    icon: Icons.class_rounded,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama kelas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                        const SizedBox(height: 16),
                          CustomInputField(
                    controller: _kapasitasController,
                    label: 'Kapasitas',
                    icon: Icons.people_rounded,
                    keyboardType: TextInputType.number,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kapasitas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                        const SizedBox(height: 16),
                        // --- GANTI TEXTFIELD DENGAN DROPDOWN BARU ---
                        AcademicYearDropdown(
                          selectedValue: _selectedTahunAjaranId,
                          onChanged: (value) {
                            setState(() {
                              _selectedTahunAjaranId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<ClassProvider>(
                    builder: (context, provider, child) {
                      return CustomLoadingButton(
                        isLoading: provider.isLoading,
                        onPressed: _submitForm,
                        text: 'Simpan',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}