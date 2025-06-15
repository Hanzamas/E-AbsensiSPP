import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/teacher/add_teacher_screen.dart';
import '../pages/teacher/teacher_list_screen.dart';
import '../provider/teacher_provider.dart';
import 'quick_action_card.dart';
import 'import_dialog_widget.dart';

class GuruSectionWidget extends StatelessWidget {
  final bool isDownloading;
  final Function(bool) onDownloadStateChanged;

  const GuruSectionWidget({
    Key? key,
    required this.isDownloading,
    required this.onDownloadStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kelola Guru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Baris pertama: Tambah dan Daftar Guru
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'Tambah Guru',
                    subtitle: 'Daftarkan Guru Baru',
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => TeacherProvider(),
                            child: const AddTeacherScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'Daftar Guru',
                    subtitle: 'Lihat & Edit Data Guru',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => TeacherProvider(),
                            child: const TeacherListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Baris kedua: Import dan Download Template
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'Import Guru',
                    subtitle: 'Import dari file Excel',
                    icon: Icons.upload_file_rounded,
                    color: const Color(0xFFFF9800),
                    onTap: () => ImportDialogWidget.show(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'Download Template',
                    subtitle: 'Template Excel Import',
                    icon: isDownloading ? null : Icons.download_rounded,
                    color: const Color(0xFF9C27B0),
                    onTap: isDownloading ? null : () => _downloadTemplate(context),
                    child: isDownloading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF9C27B0),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _downloadTemplate(BuildContext context) async {
    onDownloadStateChanged(true);

    try {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      final filePath = await provider.downloadTeacherTemplate();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template berhasil diunduh di: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onDownloadStateChanged(false);
    }
  }
}