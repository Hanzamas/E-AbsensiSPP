import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/teacher_provider.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/gender_dropdown_widget.dart';
import '../../widgets/custom_loading_button.dart';
import '../../widgets/form_section_header.dart';
import '../../widgets/date_picker_helper.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({Key? key}) : super(key: key);

  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nipController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _pendidikanTerakhirController = TextEditingController();
  final _tempLahirController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _selectedJenisKelamin;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    _namaLengkapController.dispose();
    _tglLahirController.dispose();
    _pendidikanTerakhirController.dispose();
    _tempLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await DatePickerHelper.selectDate(
      context: context,
      currentDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tglLahirController.text = '${picked.day}-${picked.month}-${picked.year}';
      });
    }
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap lengkapi semua data termasuk tanggal lahir'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    String formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    final payload = {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "role": "guru",
      "nip": _nipController.text.trim(),
      "nama_lengkap": _namaLengkapController.text.trim(),
      "jenis_kelamin": _selectedJenisKelamin,
      "tanggal_lahir": formattedDate,
      "tempat_lahir": _tempLahirController.text.trim(),
      "alamat": _alamatController.text.trim(),
      "pendidikan_terakhir": _pendidikanTerakhirController.text.trim(),
    };

    try {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      await provider.addTeacher(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Guru berhasil ditambahkan!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
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
          title: const Text('Tambah Guru'),
          backgroundColor: const Color(0xFF2196F3)),
      body: SingleChildScrollView(
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
                onChanged: (value) => setState(() => _selectedJenisKelamin = value),
              ),
              const SizedBox(height: 16),
              CustomDateField(
                controller: _tglLahirController,
                label: 'Tanggal Lahir',
                icon: Icons.calendar_today_rounded,
                onTap: _selectDate,
                validator: (v) => v!.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
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
                label: 'Password',
                icon: Icons.lock_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              CustomLoadingButton(
                isLoading: _isLoading,
                onPressed: _saveTeacher,
                text: 'Simpan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}