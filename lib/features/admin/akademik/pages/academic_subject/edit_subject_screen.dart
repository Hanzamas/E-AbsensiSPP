import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/subject_model.dart';
import '../../provider/subject_provider.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_loading_button.dart';

class EditSubjectScreen extends StatefulWidget {
  final SubjectModel subject;
  const EditSubjectScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _EditSubjectScreenState createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.subject.nama);
    _deskripsiController = TextEditingController(text: widget.subject.deskripsi);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _updateForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedSubject = SubjectModel(
        id: widget.subject.id,
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
      );

      final provider = Provider.of<SubjectProvider>(context, listen: false);
      final success = await provider.updateSubject(widget.subject.id!, updatedSubject);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${provider.error}'), backgroundColor: Colors.red),
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
        title: const Text('Edit Mata Pelajaran', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
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
