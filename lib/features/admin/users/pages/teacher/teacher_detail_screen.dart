import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart'; // Pastikan Anda sudah membuat model ini dari langkah sebelumnya
// import 'edit_teacher_screen.dart'; // Anda bisa hubungkan ini nanti

class TeacherDetailScreen extends StatelessWidget {
  final Teacher teacher;

  const TeacherDetailScreen({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Guru',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard('Informasi Guru', {
              'ID Guru': teacher.id.toString(),
              'Nama Lengkap': teacher.namaLengkap,
              'NIP': teacher.nip,
              'Jenis Kelamin': teacher.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
              'Tempat Lahir': teacher.tempatLahir,
              'Tanggal Lahir': _formatDate(teacher.tanggalLahir), // Pertimbangkan untuk format tanggal ini
              'Alamat': teacher.alamat,
              'Pendidikan Terakhir': teacher.pendidikanTerakhir,
            }),
            const SizedBox(height: 20),
            _buildInfoCard('Informasi Akun', {
              'Email': teacher.email,
              'Username': teacher.username,
              'Role': teacher.role,
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

  // Method untuk format tanggal
  String _formatDate(String date) {
    if (date.isEmpty) return 'Tidak tersedia';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }