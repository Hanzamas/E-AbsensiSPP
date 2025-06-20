import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/class_model.dart';
import '../../provider/class_provider.dart';
import '../../widgets/academic_year_dropdown.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_loading_button.dart';

class EditClassScreen extends StatefulWidget {
  final ClassModel classData;
  const EditClassScreen({Key? key, required this.classData}) : super(key: key);

  @override
  _EditClassScreenState createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _kapasitasController;
  late int? _selectedTahunAjaranId;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.classData.namaKelas);
    _kapasitasController = TextEditingController(text: widget.classData.kapasitas.toString());
    _selectedTahunAjaranId = widget.classData.idTahunAjaran;

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

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTahunAjaranId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahun Ajaran wajib dipilih'), backgroundColor: Colors.red),
      );
      return;
    }

    final updatedClass = ClassModel(
      id: widget.classData.id,
      namaKelas: _namaController.text,
      kapasitas: int.parse(_kapasitasController.text),
      idTahunAjaran: _selectedTahunAjaranId!,
      tahunAjaran: widget.classData.tahunAjaran,
    );

    final provider = Provider.of<ClassProvider>(context, listen: false);
    final success = await provider.updateClass(widget.classData.id, updatedClass);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kelas berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${provider.error}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edit Kelas'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                    )
                  ],
                ),
                child: Column(
                  children: [                    CustomInputField(
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
                    const SizedBox(height: 16),                    CustomInputField(
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
                    onPressed: _updateForm,
                    text: 'Simpan Perubahan',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
