// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../provider/student_provider.dart';

// class AddStudentScreen extends StatefulWidget {
//   const AddStudentScreen({Key? key}) : super(key: key);

//   @override
//   _AddStudentScreenState createState() => _AddStudentScreenState();
// }

// class _AddStudentScreenState extends State<AddStudentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _kelasController = TextEditingController();
//   final _nisController = TextEditingController();
//   final _nama_lengkapController = TextEditingController();
//   final _tgl_lahirController = TextEditingController();
//   final _temp_lahirController = TextEditingController();
//   final _alamatController = TextEditingController();
//   final _waliController = TextEditingController();
//   final _waliwa_waliController = TextEditingController();
  
//   String? _selectedJenisKelamin;
//   DateTime? _selectedDate;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _kelasController.dispose();
//     _nisController.dispose();
//     _nama_lengkapController.dispose();
//     _tgl_lahirController.dispose();
//     _temp_lahirController.dispose();
//     _alamatController.dispose();
//     _waliController.dispose();
//     _waliwa_waliController.dispose();
//     super.dispose();
//   }

//   // --- Fungsi untuk menampilkan Date Picker ---
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime today = DateTime.now();
//     final DateTime firstDate = DateTime(1980);
//     final DateTime lastDate = DateTime(today.year + 1, 12, 31);

//     // Pastikan initialDate tidak melebihi lastDate
//     DateTime initialDate;
//     if (_selectedDate != null) {
//       if (_selectedDate!.isAfter(lastDate)) {
//         initialDate = today; // Gunakan hari ini jika tanggal yang ada melebihi batas
//       } else if (_selectedDate!.isBefore(firstDate)) {
//         initialDate = firstDate; // Gunakan firstDate jika tanggal yang ada terlalu lama
//       } else {
//         initialDate = _selectedDate!;
//       }
//     } else {
//       initialDate = today;
//     }

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//       // Parameter locale dihapus untuk menghindari error MaterialLocalizations
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//             _tgl_lahirController.text = _formatDateIndonesian(picked);
//       });
//     }
//   }

//   // --- Helper untuk format tanggal ke bahasa Indonesia ---
//   String _formatDateIndonesian(DateTime date) {
//     List<String> months = [
//       '',
//       'Januari',
//       'Februari',
//       'Maret',
//       'April',
//       'Mei',
//       'Juni',
//       'Juli',
//       'Agustus',
//       'September',
//       'Oktober',
//       'November',
//       'Desember',
//     ];

//     return '${date.day} ${months[date.month]} ${date.year}';
//   }

//   // --- Fungsi untuk mengirim data ke API ---
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       // Validasi tambahan untuk tanggal lahir
//       if (_selectedDate == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Tanggal lahir tidak boleh kosong.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       setState(() => _isLoading = true);

//       final provider = Provider.of<StudentProvider>(context, listen: false);

//       // Format tanggal sesuai permintaan API ("yyyy-MM-dd")
//       final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

//       // Payload disesuaikan dengan dokumentasi API
//       final studentData = {
//         'username': _usernameController.text,
//         'email': _emailController.text,
//         'password': _passwordController.text,
//         'nis': _nisController.text,
//         'nama_lengkap': _nama_lengkapController.text,
//         'jenis_kelamin': _selectedJenisKelamin,
//         'tanggal_lahir': formattedDate, // <-- Format yyyy-MM-dd untuk API
//         'tempat_lahir': _temp_lahirController.text,
//         'alamat': _alamatController.text,
//         'wali': _waliController.text,
//         'wa_wali': _waliwa_waliController.text,
//         'id_kelas': int.tryParse(_kelasController.text) ?? 0,
//       };

//       final success = await provider.createStudent(studentData);

//       if (mounted) {
//         setState(() => _isLoading = false);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Siswa berhasil ditambahkan'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context, true);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Gagal menambahkan siswa: ${provider.error}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.add_circle_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Tambah Siswa',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF2196F3),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       children: [
//                         _buildInputField(
//                           controller: _usernameController,
//                           label: 'Username',
//                           hint: 'Contoh: yoga',
//                           icon: Icons.person_rounded,
//                           validator: (v) => v!.isEmpty ? 'Username tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _emailController,
//                           label: 'Email',
//                           hint: 'Contoh: yoga12@gmail.com',
//                           icon: Icons.email_rounded,
//                           keyboardType: TextInputType.emailAddress,
//                            validator: (value) {
//                             if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
//                             final emailRegex = RegExp(r"^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$");
//                             if (!emailRegex.hasMatch(value)) return 'Masukkan email valid';
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _passwordController,
//                           label: 'Password',
//                           hint: 'Contoh: yoga123?',
//                           icon: Icons.lock_rounded,
//                           obscureText: true,
//                            validator: (value) {
//                             if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
//                             if (value.length < 6) return 'Password minimal 6 karakter';
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                          _buildInputField(
//                           controller: _kelasController,
//                           label: 'ID Kelas',
//                           hint: 'Contoh: 12',
//                           icon: Icons.class_rounded,
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) return 'ID Kelas tidak boleh kosong';
//                             if (int.tryParse(value) == null) return 'ID Kelas harus berupa angka';
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _nisController,
//                           label: 'NIS',
//                           hint: 'Contoh: 1234567890',
//                           icon: Icons.confirmation_num_rounded,
//                           keyboardType: TextInputType.number,
//                           validator: (v) => v!.isEmpty ? 'NIS tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _nama_lengkapController,
//                           label: 'Nama Lengkap',
//                           hint: 'Contoh: Yoga Pratama',
//                           icon: Icons.person_rounded,
//                           validator: (v) => v!.isEmpty ? 'Nama Lengkap tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildDropdownField(
//                           value: _selectedJenisKelamin,
//                           label: 'Jenis Kelamin',
//                           hint: 'Pilih jenis kelamin',
//                           icon: Icons.wc_rounded,
//                           items: const ['L', 'P'],
//                           itemLabels: const ['Laki-laki', 'Perempuan'],
//                           onChanged: (value) => setState(() => _selectedJenisKelamin = value),
//                           validator: (v) => v == null ? 'Jenis Kelamin tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
                        
//                         // --- Widget Tanggal Lahir (Dengan locale Indonesia) ---
//                         TextFormField(
//                           controller: _tgl_lahirController,
//                           decoration: InputDecoration(
//                             labelText: 'Tanggal Lahir',
//                             hintText: 'Pilih tanggal lahir',
//                             prefixIcon: Icon(Icons.calendar_today_rounded, color: const Color(0xFF2196F3)),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade50,
//                           ),
//                           readOnly: true,
//                           onTap: () => _selectDate(context),
//                           validator: (value) => (value == null || value.isEmpty)
//                               ? 'Tanggal Lahir tidak boleh kosong'
//                               : null,
//                         ),
//                         const SizedBox(height: 16),

//                         _buildInputField(
//                           controller: _temp_lahirController,
//                           label: 'Tempat Lahir',
//                           hint: 'Contoh: Lamongan',
//                           icon: Icons.location_on_rounded,
//                           validator: (v) => v!.isEmpty ? 'Tempat Lahir tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _alamatController,
//                           label: 'Alamat',
//                           hint: 'Contoh: Jl. Merdeka No. 123',
//                           icon: Icons.home_rounded,
//                           validator: (v) => v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildInputField(
//                           controller: _waliController,
//                           label: 'Nama Wali',
//                           hint: 'Contoh: Denny Caknan',
//                           icon: Icons.person_outline_rounded,
//                           validator: (v) => v!.isEmpty ? 'Nama Wali tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                          _buildInputField(
//                           controller: _waliwa_waliController,
//                           label: 'No WhatsApp Wali',
//                           hint: 'Contoh: 6285123456789',
//                           icon: Icons.phone_rounded,
//                           keyboardType: TextInputType.phone,
//                           validator: (v) => v!.isEmpty ? 'No WhatsApp Wali tidak boleh kosong' : null,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2196F3),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Text(
//                               'Simpan',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     bool obscureText = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2196F3)),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }

//   Widget _buildDropdownField({
//     required String? value,
//     required String label,
//     required String hint,
//     required IconData icon,
//     required List<String> items,
//     required List<String> itemLabels,
//     required void Function(String?) onChanged,
//     String? Function(String?)? validator,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2196F3)),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//       ),
//       items: items.asMap().entries.map((entry) {
//         return DropdownMenuItem<String>(
//           value: entry.value,
//           child: Text(itemLabels[entry.key]),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       validator: validator,
//     );
//   }
// }