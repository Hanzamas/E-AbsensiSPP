import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/subject_model.dart';
import '../../provider/subject_provider.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_loading_button.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({Key? key}) : super(key: key);

  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newSubject = SubjectModel(
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
      );

      final provider = Provider.of<SubjectProvider>(context, listen: false);
      final success = await provider.createSubject(newSubject);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mata pelajaran berhasil ditambahkan!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${provider.error ?? "Gagal menyimpan data"}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tambah Mata Pelajaran', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                    CustomInputField(
                      controller: _namaController,
                      label: 'Nama Mata Pelajaran',
                      icon: Icons.book_rounded,
                      customValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama mata pelajaran tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _deskripsiController,
                      label: 'Deskripsi',
                      icon: Icons.description_rounded,
                      customValidator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<SubjectProvider>(
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
    );
  }
}
