import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/teacher_provider.dart';
import '../../data/models/teacher_model.dart';
import 'teacher_detail_screen.dart';
import 'edit_teacher_screen.dart';
// Impor widget filter yang baru dibuat
import '../../widgets/filter_and_sort_widget.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({Key? key}) : super(key: key);

  @override
  _TeacherListScreenState createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat data guru saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
    });
  }

  // Menampilkan dialog konfirmasi sebelum menghapus
  void _showDeleteConfirmation(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data guru "${teacher.namaLengkap}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Memanggil provider untuk menghapus data
                Provider.of<TeacherProvider>(context, listen: false)
                    .deleteTeacher(teacher.idUsers)
                    .then((_) => Navigator.of(ctx).pop())
                    .catchError(
                      (_) => Navigator.of(ctx).pop(), // Tutup dialog jika terjadi error
                    );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Guru'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 1. WIDGET FILTER DITAMBAHKAN DI SINI
              FilterAndSortWidget(
                onApplyFilter: (query, order) {
                  provider.applyFilters(query, order);
                },
                onResetFilter: () {
                  provider.resetFilters();
                },
              ),
              // 2. KONDISI UI DISESUAIKAN
              // Kondisi saat sedang memuat data
              if (provider.isLoading && provider.teachers.isEmpty)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              // Kondisi jika terjadi error
              else if (provider.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Terjadi kesalahan: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchTeachers(),
                          child: const Text('Coba Lagi'),
                        )
                      ],
                    ),
                  ),
                )
              // Kondisi jika data kosong setelah filter atau dari awal
              else if (provider.teachers.isEmpty)
                const Expanded(
                    child: Center(child: Text('Tidak ada data guru.')))
              // Tampilan daftar guru jika data tersedia
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchTeachers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      // Gunakan panjang daftar yang sudah difilter
                      itemCount: provider.teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = provider.teachers[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2196F3),
                              child: Text(
                                teacher.namaLengkap.isNotEmpty
                                    ? teacher.namaLengkap[0]
                                    : 'G',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              teacher.namaLengkap,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'NIP: ${teacher.nip}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Edit
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    final teacherProvider =
                                        Provider.of<TeacherProvider>(context,
                                            listen: false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChangeNotifierProvider.value(
                                            value: teacherProvider,
                                            child: EditTeacherScreen(
                                                teacher: teacher),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                // Tombol Hapus
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmation(context, teacher),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigasi ke halaman detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherDetailScreen(teacher: teacher),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}