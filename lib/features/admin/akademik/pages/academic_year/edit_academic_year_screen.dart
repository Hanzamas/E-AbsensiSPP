import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/academic_year_model.dart';
import '../../provider/academic_year_provider.dart';
import '../../widgets/academic_date_picker_helper.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_date_field.dart';
import '../../../../shared/widgets/custom_loading_button.dart';

class EditAcademicYearScreen extends StatefulWidget {
  final AcademicYearModel academicYear;
  const EditAcademicYearScreen({Key? key, required this.academicYear}) : super(key: key);

  @override
  _EditAcademicYearScreenState createState() => _EditAcademicYearScreenState();
}

class _EditAcademicYearScreenState extends State<EditAcademicYearScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _tanggalMulaiController;
  late TextEditingController _tanggalSelesaiController;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.academicYear.nama);
    _selectedStartDate = widget.academicYear.tanggalMulai;
    _selectedEndDate = widget.academicYear.tanggalSelesai;

    _tanggalMulaiController = TextEditingController(
        text: AcademicDatePickerHelper.formatDateIndonesian(_selectedStartDate!));
    _tanggalSelesaiController = TextEditingController(
        text: AcademicDatePickerHelper.formatDateIndonesian(_selectedEndDate!));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

   Future<void> _selectStartDate() async {
    final DateTime? picked = await AcademicDatePickerHelper.selectDate(
      context: context,
      currentDate: _selectedStartDate,
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _tanggalMulaiController.text = AcademicDatePickerHelper.formatDateIndonesian(picked);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await AcademicDatePickerHelper.selectDate(
      context: context,
      currentDate: _selectedEndDate,
      firstDate: _selectedStartDate,
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _tanggalSelesaiController.text = AcademicDatePickerHelper.formatDateIndonesian(picked);
      });
    }
  }

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final updatedData = AcademicYearModel(
      id: widget.academicYear.id,
      nama: _namaController.text,
      tanggalMulai: _selectedStartDate!,
      tanggalSelesai: _selectedEndDate!,
    );

    final provider = Provider.of<AcademicYearProvider>(context, listen: false);
    final success = await provider.updateAcademicYear(widget.academicYear.id!, updatedData);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui!'), backgroundColor: Colors.green),
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
        title: const Text('Edit Tahun Ajaran', style: TextStyle(color: Colors.white)),
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
              // ====== PEMBUNGKUS KARTU UNTUK FORM INPUT ======
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
                  children: [
                    CustomInputField(
                      controller: _namaController,
                      label: 'Nama Tahun Ajaran',
                      icon: Icons.school_rounded,
                       customValidator: (value) {
                        if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                        if (!RegExp(r'^\d{4}\/\d{4}$').hasMatch(value)) return 'Format harus YYYY/YYYY, contoh: 2025/2026';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomDateField(
                      controller: _tanggalMulaiController,
                      label: 'Tanggal Mulai',
                      icon: Icons.calendar_today_rounded,
                      onTap: _selectStartDate,
                    ),
                    const SizedBox(height: 16),
                    CustomDateField(
                      controller: _tanggalSelesaiController,
                      label: 'Tanggal Selesai',
                      icon: Icons.event_rounded,
                      onTap: _selectEndDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<AcademicYearProvider>(
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