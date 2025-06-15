// screens/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/student_provider.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_loading_button.dart';
import '../../widgets/gender_dropdown_widget.dart';
import '../../widgets/date_picker_helper.dart';
import '../../widgets/form_section_header.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kelasController = TextEditingController();
  final _nisController = TextEditingController();
  final _nama_lengkapController = TextEditingController();
  final _tgl_lahirController = TextEditingController();
  final _temp_lahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _waliController = TextEditingController();
  final _waliwa_waliController = TextEditingController();

  String? _selectedJenisKelamin;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nisController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _kelasController.dispose();
    _nama_lengkapController.dispose();
    _tgl_lahirController.dispose();
    _temp_lahirController.dispose();
    _alamatController.dispose();
    _waliController.dispose();
    _waliwa_waliController.dispose();
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
        _tgl_lahirController.text = DatePickerHelper.formatDateIndonesian(
          picked,
        );
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Format tanggal ke YYYY-MM-DD untuk API
    String? formattedDate;
    if (_selectedDate != null) {
      formattedDate =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    }

    // Siapkan payload sesuai dokumentasi API
    final payload = {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "id_kelas": int.tryParse(_kelasController.text.trim()) ?? 0,
      "nis": _nisController.text.trim(),
      "nama_lengkap": _nama_lengkapController.text.trim(),
      "jenis_kelamin": _selectedJenisKelamin ?? "",
      "tanggal_lahir": formattedDate ?? "",
      "tempat_lahir": _temp_lahirController.text.trim(),
      "alamat": _alamatController.text.trim(),
      "wali": _waliController.text.trim(),
      "wa_wali": _waliwa_waliController.text.trim(),
    };

    try {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      await studentProvider.addStudent(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Siswa berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa'),
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
                  controller: _nama_lengkapController,
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
                  onChanged:
                      (value) => setState(() {
                        _selectedJenisKelamin = value;
                      }),
                ),
                const SizedBox(height: 16),

                CustomDateField(
                  controller: _tgl_lahirController,
                  label: 'Tanggal Lahir',
                  icon: Icons.calendar_today,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  controller: _temp_lahirController,
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
                  controller: _waliwa_waliController,
                  label: 'No. WhatsApp Wali',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _kelasController,
                  label: 'ID Kelas',
                  icon: Icons.class_,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                const FormSectionHeader(title: 'Informasi Akun'),
                CustomInputField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.account_circle,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 24),

                CustomLoadingButton(
                  isLoading: _isLoading,
                  onPressed: _saveStudent,
                  text: 'Simpan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
