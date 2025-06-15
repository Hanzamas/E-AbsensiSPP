import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/teacher_provider.dart';

class ImportDialogWidget {
  static void show(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final teacherProvider = Provider.of<TeacherProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.upload_file_rounded, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text('Import Data Guru'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload file Excel (.xlsx) yang berisi data guru.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Validasi yang akan dilakukan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildValidationItem('Username harus unik'),
              _buildValidationItem('Email harus unik dan valid'),
              _buildValidationItem('NIP harus unik'),
              _buildValidationItem('Password minimal 6 karakter'),
              _buildValidationItem('Role harus "guru"'),
              _buildValidationItem('Semua field wajib diisi'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // 1. Buka File Picker untuk memilih file .xlsx
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx'],
                  );

                  // 2. Jika pengguna tidak memilih file, keluar dari fungsi
                  if (result == null || result.files.single.path == null) {
                    Navigator.of(dialogContext).pop();
                    return;
                  }

                  String filePath = result.files.single.path!;

                  // 3. Tutup dialog setelah file dipilih
                  Navigator.of(dialogContext).pop();

                  // 4. Tampilkan loading indicator sementara
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Sedang mengimpor data...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.blue,
                    ),
                  );

                  // 5. Panggil provider untuk memulai proses import
                  final message = await teacherProvider.importTeachers(filePath);

                  // 6. Jika sampai sini berarti import berhasil
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } catch (error) {
                  // 7. Tangani error dari import
                  print('Import error: $error'); // Untuk debugging

                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Import Gagal: ${error.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Pilih File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildValidationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}