import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../data/models/student_model.dart';
import '../../provider/student_provider.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/gender_dropdown_widget.dart';
import '../../widgets/custom_loading_button.dart';
import '../../widgets/form_section_header.dart';
import '../../widgets/date_picker_helper.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;
  const EditStudentScreen({Key? key, required this.student}) : super(key: key);

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _nisController;
  late TextEditingController _namaLengkapController;
  late TextEditingController _tglLahirController;
  late TextEditingController _tempLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _waliController;
  late TextEditingController _waWaliController;

  String? _selectedJenisKelamin;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeGender();
    _initializeDate();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController(text: widget.student.username);
    _emailController = TextEditingController(text: widget.student.email);
    _nisController = TextEditingController(text: widget.student.nis);
    _namaLengkapController = TextEditingController(
      text: widget.student.namaLengkap,
    );
    _tempLahirController = TextEditingController(
      text: widget.student.tempatLahir,
    );
    _alamatController = TextEditingController(text: widget.student.alamat);
    _waliController = TextEditingController(text: widget.student.wali);
    _waWaliController = TextEditingController(text: widget.student.waWali);
    _tglLahirController = TextEditingController();
  }

  void _initializeGender() {
    final initialJenisKelamin = widget.student.jenisKelamin;
    if (initialJenisKelamin == 'L' || initialJenisKelamin == 'P') {
      _selectedJenisKelamin = initialJenisKelamin;
    } else {
      _selectedJenisKelamin = null;
    }
  }

  void _initializeDate() {
    _selectedDate = DatePickerHelper.parseDateSafely(widget.student.tanggalLahir);
    if (_selectedDate != null) {
      _tglLahirController.text = DatePickerHelper.formatDateIndonesian(_selectedDate!);
    } else {
      _tglLahirController.text = "";
    }
  }

  @override
  void dispose() {
    _nisController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _namaLengkapController.dispose();
    _tglLahirController.dispose();
    _tempLahirController.dispose();
    _alamatController.dispose();
    _waliController.dispose();
    _waWaliController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await DatePickerHelper.selectDate(
      context: context,
      currentDate: _selectedDate,
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tglLahirController.text = DatePickerHelper.formatDateIndonesian(_selectedDate!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal lahir tidak boleh kosong'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<StudentProvider>(context, listen: false);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final studentData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'nis': _nisController.text,
        'nama_lengkap': _namaLengkapController.text,
        'jenis_kelamin': _selectedJenisKelamin,
        'tanggal_lahir': formattedDate,
        'tempat_lahir': _tempLahirController.text,
        'alamat': _alamatController.text,
        'wali': _waliController.text,
        'wa_wali': _waWaliController.text,
        'id_kelas': widget.student.idKelas,
      };

      print('Data yang dikirim ke server:');
      print(jsonEncode(studentData));

      final success = await provider.updateStudent(
        widget.student.id,
        studentData,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data siswa berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui data: ${provider.error ?? "Periksa kembali data Anda"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.student.namaLengkap}'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormSectionHeader(title: 'Informasi Pribadi'),
                CustomInputField(
                  controller: _namaLengkapController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _nisController,
                  label: 'NIS',
                  icon: Icons.confirmation_num_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                GenderDropdownWidget(
                  selectedGender: _selectedJenisKelamin,
                  onChanged: (value) {
                    setState(() {
                      _selectedJenisKelamin = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomDateField(
                  controller: _tglLahirController,
                  label: 'Tanggal Lahir',
                  icon: Icons.calendar_today,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _tempLahirController,
                  label: 'Tempat Lahir',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _alamatController,
                  label: 'Alamat',
                  icon: Icons.home_rounded,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _waliController,
                  label: 'Nama Wali',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _waWaliController,
                  label: 'No. WhatsApp Wali',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                const FormSectionHeader(title: 'Informasi Akun'),
                CustomInputField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.people,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  // isRequired: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Consumer<StudentProvider>(
                  builder: (context, provider, child) {
                    return CustomLoadingButton(
                      isLoading: provider.isLoading,
                      onPressed: _submitForm,
                      text: 'Simpan Perubahan',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}