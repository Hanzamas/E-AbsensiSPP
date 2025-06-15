import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Siswa'),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to an edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard('Informasi Siswa', { //
              'Nama Siswa': student.namaLengkap,
              'NIS': student.nis,
              'Kelas': student.namaKelas,
              'Jenis Kelamin': student.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
              'Tempat Lahir': student.tempatLahir,
              'Tanggal Lahir': _formatDate(student.tanggalLahir), // Consider formatting this date
              'Alamat': student.alamat,
              // 'Email': student.email,
              'Username': student.username,
            }),
            const SizedBox(height: 20),
            _buildInfoCard('Informasi Wali', {
              'Nama Wali': student.wali,
              'No. WhatsApp Wali': student.waWali,
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
            const SizedBox(height: 12),
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: Text(entry.key, style: TextStyle(color: Colors.grey.shade600))),
                      Expanded(flex: 3, child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
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