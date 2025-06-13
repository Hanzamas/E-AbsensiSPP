import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../data/models/student_model.dart';
import '../provider/student_provider.dart';

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

    // Memeriksa validitas data jenis kelamin sebelum menampilkannya
    final initialJenisKelamin = widget.student.jenisKelamin;
    if (initialJenisKelamin == 'L' || initialJenisKelamin == 'P') {
      _selectedJenisKelamin = initialJenisKelamin;
    } else {
      // Jika data dari server adalah "" atau tidak valid, set ke null
      _selectedJenisKelamin = null;
    }

    _tglLahirController = TextEditingController();
    try {
      _selectedDate = DateTime.parse(widget.student.tanggalLahir);
      // Validasi tanggal yang diparsing
      final DateTime today = DateTime.now();
      final DateTime maxDate = DateTime(today.year + 1, 12, 31);
      final DateTime minDate = DateTime(1980);

      // Jika tanggal di luar rentang yang wajar, reset ke null
      if (_selectedDate!.isAfter(maxDate) || _selectedDate!.isBefore(minDate)) {
        print(
          'Tanggal tidak valid: ${widget.student.tanggalLahir}. Reset ke null.',
        );
        _selectedDate = null;
        _tglLahirController.text = "";
      } else {
        _tglLahirController.text = _formatDateIndonesian(_selectedDate!);
      }
    } catch (e) {
      print('Error parsing tanggal: ${widget.student.tanggalLahir}. Error: $e');
      _selectedDate = null;
      _tglLahirController.text = ""; // Biarkan kosong jika format tidak valid
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

  // ALTERNATIF 1: HAPUS PARAMETER LOCALE DARI SHOWDATEPICKER
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(1980);
    final DateTime lastDate = DateTime(
      today.year + 1,
      12,
      31,
    ); // Atau gunakan DateTime.now()

    // Pastikan initialDate tidak melebihi lastDate
    DateTime initialDate;
    if (_selectedDate != null) {
      if (_selectedDate!.isAfter(lastDate)) {
        initialDate =
            today; // Gunakan hari ini jika tanggal yang ada melebihi batas
      } else if (_selectedDate!.isBefore(firstDate)) {
        initialDate =
            firstDate; // Gunakan firstDate jika tanggal yang ada terlalu lama
      } else {
        initialDate = _selectedDate!;
      }
    } else {
      initialDate = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // Parameter locale dihapus untuk menghindari error MaterialLocalizations
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tglLahirController.text = _formatDateIndonesian(_selectedDate!);
      });
    }
  }

  // HELPER FUNCTION: FORMAT TANGGAL INDONESIA MANUAL
  String _formatDateIndonesian(DateTime date) {
    List<String> months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
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
                _buildInputField(
                  controller: _namaLengkapController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _nisController,
                  label: 'NIS',
                  icon: Icons.confirmation_num_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tglLahirController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: const Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Tanggal Lahir tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _tempLahirController,
                  label: 'Tempat Lahir',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _alamatController,
                  label: 'Alamat',
                  icon: Icons.home_rounded,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _waliController,
                  label: 'Nama Wali',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _waWaliController,
                  label: 'No. WhatsApp Wali',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.people,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2196F3),
                    ),
                    child: Consumer<StudentProvider>(
                      builder: (context, provider, child) {
                        return provider.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator:
          (value) =>
              (value == null || value.isEmpty)
                  ? '$label tidak boleh kosong'
                  : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedJenisKelamin,
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        prefixIcon: Icon(Icons.wc, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedJenisKelamin = value;
        });
      },
      validator:
          (value) =>
              (value == null || value.isEmpty)
                  ? 'Jenis Kelamin tidak boleh kosong'
                  : null,
    );
  }
}
