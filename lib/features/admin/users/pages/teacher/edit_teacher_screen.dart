import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../data/models/teacher_model.dart';
import '../../provider/teacher_provider.dart';
import '../../../../shared/widgets/custom_input_field.dart';
import '../../../../shared/widgets/custom_date_field.dart';
import '../../widgets/gender_dropdown_widget.dart';
import '../../../../shared/widgets/custom_loading_button.dart';
import '../../widgets/form_section_header.dart';
import '../../widgets/date_picker_helper.dart';

class EditTeacherScreen extends StatefulWidget {
  final Teacher teacher;
  const EditTeacherScreen({Key? key, required this.teacher}) : super(key: key);

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nipController;
  late TextEditingController _namaLengkapController;
  late TextEditingController _tglLahirController;
  late TextEditingController _tempLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _pendidikanTerakhirController;

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
    _usernameController = TextEditingController(text: widget.teacher.username);
    _emailController = TextEditingController(text: widget.teacher.email);
    _passwordController = TextEditingController(); // Dibiarkan kosong secara default
    _nipController = TextEditingController(text: widget.teacher.nip);
    _namaLengkapController =
        TextEditingController(text: widget.teacher.namaLengkap);
    _tempLahirController =
        TextEditingController(text: widget.teacher.tempatLahir);
    _alamatController = TextEditingController(text: widget.teacher.alamat);
    _pendidikanTerakhirController =
        TextEditingController(text: widget.teacher.pendidikanTerakhir);
    _tglLahirController = TextEditingController();
  }

  void _initializeGender() {
    final initialJenisKelamin = widget.teacher.jenisKelamin;
    if (initialJenisKelamin == 'L' || initialJenisKelamin == 'P') {
      _selectedJenisKelamin = initialJenisKelamin;
    } else {
      _selectedJenisKelamin = null;
    }
  }

  void _initializeDate() {
    _selectedDate = DatePickerHelper.parseDateSafely(widget.teacher.tanggalLahir);
    if (_selectedDate != null) {
      _tglLahirController.text = DatePickerHelper.formatDateIndonesian(_selectedDate!);
    } else {
      _tglLahirController.text = "";
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    _namaLengkapController.dispose();
    _tglLahirController.dispose();
    _tempLahirController.dispose();
    _alamatController.dispose();
    _pendidikanTerakhirController.dispose();
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

  Future<void> _updateTeacher() async {
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

      final provider = Provider.of<TeacherProvider>(context, listen: false);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final teacherData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'nip': _nipController.text,
        'nama_lengkap': _namaLengkapController.text,
        'jenis_kelamin': _selectedJenisKelamin,
        'tanggal_lahir': formattedDate,
        'tempat_lahir': _tempLahirController.text,
        'alamat': _alamatController.text,
        'pendidikan_terakhir': _pendidikanTerakhirController.text,
        'role': 'guru',
      };

      // Tambahkan password ke payload hanya jika diisi
      if (_passwordController.text.isNotEmpty) {
        teacherData['password'] = _passwordController.text;
      }

      print('Data yang dikirim ke server:');
      print(jsonEncode(teacherData));

      final success = await provider.updateTeacher(
        widget.teacher.idUsers,
        teacherData,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data guru berhasil diperbarui'),
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
        title: Text('Edit ${widget.teacher.namaLengkap}',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  controller: _nipController,
                  label: 'NIP',
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
                  controller: _pendidikanTerakhirController,
                  label: 'Pendidikan Terakhir',
                  icon: Icons.school_rounded,
                ),
                const SizedBox(height: 24),
                const FormSectionHeader(title: 'Informasi Akun'),
                CustomInputField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.account_circle_rounded,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _passwordController,
                  label: 'Password Baru (Opsional)',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  isRequired: false,
                ),
                const SizedBox(height: 24),
                Consumer<TeacherProvider>(
                  builder: (context, provider, child) {
                    return CustomLoadingButton(
                      isLoading: provider.isLoading,
                      onPressed: _updateTeacher,
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