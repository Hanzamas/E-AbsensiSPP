import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../data/models/class_model.dart';
// import '../provider/class_provider.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kelasController = TextEditingController();
  final _nisController = TextEditingController();
  final _nama_lengkapController = TextEditingController();
  final _jenis_kelaminController = TextEditingController();
  final _tgl_lahirController = TextEditingController();
  final _temp_lahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _waliController = TextEditingController();
  final _waliwa_waliController = TextEditingController();
  String? _selectedJenisKelamin;

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _kelasController.dispose();
    _nisController.dispose();
    _nama_lengkapController.dispose();
    _jenis_kelaminController.dispose();
    _tgl_lahirController.dispose();
    _temp_lahirController.dispose();
    _alamatController.dispose();
    _waliController.dispose();
    _waliwa_waliController.dispose();
    super.dispose();
  }

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() => _isLoading = true);
  //     try {
  //       final newClass = ClassModel(
  //         id: 0,
  //         namaKelas: _namaController.text,
  //         kapasitas: int.parse(_kapasitasController.text),
  //         idTahunAjaran: int.parse(_tahunAjaranController.text),
  //         tahunAjaran: '', // This will be set by the server
  //       );

  //       final provider = Provider.of<ClassProvider>(context, listen: false);
  //       final success = await provider.createClass(newClass);

  //       if (success && mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Kelas berhasil ditambahkan'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         Navigator.pop(context, true);
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error: ${e.toString()}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } finally {
  //       if (mounted) {
  //         setState(() => _isLoading = false);
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tambah Siswa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Contoh: yoga',
                          icon: Icons.person_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Contoh: yoga12@gmail.com',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            final emailRegex = RegExp(
                              r"^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$",
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Masukkan email valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Contoh: yoga123?',
                          icon: Icons.lock_rounded,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _kelasController,
                          label: 'Kelas',
                          hint: 'Contoh: XII RPL 1',
                          icon: Icons.class_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kelas tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _nisController,
                          label: 'NIS',
                          hint: 'Contoh: 1234567890',
                          icon: Icons.confirmation_num_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIS tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'NIS harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _nama_lengkapController,
                          label: 'Nama Lengkap',
                          hint: 'Contoh: Yoga Pratama',
                          icon: Icons.person_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Lengkap tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildDropdownField(
                          value: _selectedJenisKelamin,
                          label: 'Jenis Kelamin',
                          hint: 'Pilih jenis kelamin',
                          icon: Icons.wc_rounded,
                          items: const ['L', 'P'],
                          itemLabels: const ['Laki-laki', 'Perempuan'],
                          onChanged: (value) {
                            setState(() {
                              _selectedJenisKelamin = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis Kelamin tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _tgl_lahirController,
                          label: 'Tanggal Lahir',
                          hint: 'Contoh: 01/01/2000',
                          icon: Icons.calendar_today_rounded,
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal Lahir tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _temp_lahirController,
                          label: 'Tempat Lahir',
                          hint: 'Contoh: Lamongan',
                          icon: Icons.location_on_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tempat Lahir tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _alamatController,
                          label: 'Alamat',
                          hint: 'Contoh: Jl. Merdeka No. 123, Lamongan',
                          icon: Icons.home_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alamat tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _waliController,
                          label: 'Nama Wali',
                          hint: 'Contoh: Denny Caknan',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Wali tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _waliwa_waliController,
                          label: 'No WhatsApp Wali',
                          hint: 'Contoh: 6285123456789',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No WhatsApp Wali tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'No WhatsApp Wali harus berupa angka';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

Widget _buildDropdownField({
  required String? value,
  required String label,
  required String hint,
  required IconData icon,
  required List<String> items,
  required List<String> itemLabels,
  required void Function(String?) onChanged,
  String? Function(String?)? validator,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    items:
        items.asMap().entries.map((entry) {
          int index = entry.key;
          String value = entry.value;
          return DropdownMenuItem<String>(
            value: value,
            child: Text(itemLabels[index]),
          );
        }).toList(),
    onChanged: onChanged,
    validator: validator,
  );
}
