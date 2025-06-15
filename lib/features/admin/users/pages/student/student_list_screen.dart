import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/student_provider.dart';
import '../../data/models/student_model.dart';
import 'student_detail_screen.dart';
import 'edit_student_screen.dart';
// Impor widget filter
import '../../widgets/filter_and_sort_widget.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch students when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    });
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data siswa "${student.namaLengkap}"?',
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
                Provider.of<StudentProvider>(context, listen: false)
                    .deleteStudent(student.id)
                    .then((_) => Navigator.of(ctx).pop())
                    .catchError((_) => Navigator.of(ctx).pop());
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
        title: const Text('Daftar Siswa'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Tambahkan widget filter di sini
              FilterAndSortWidget(
                onApplyFilter: (query, order) {
                  provider.applyFilters(query, order);
                },
                onResetFilter: () {
                  provider.resetFilters();
                },
              ),

              // Tampilkan konten berdasarkan state dari provider
              if (provider.isLoading && provider.students.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                Expanded(child: Center(child: Text('Error: ${provider.error}')))
              else if (provider.students.isEmpty)
                const Expanded(
                  child: Center(child: Text('Tidak ada data siswa.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: provider.students.length,
                    itemBuilder: (context, index) {
                      final student = provider.students[index];
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
                              student.namaLengkap.isNotEmpty
                                  ? student.namaLengkap[0]
                                  : 'S',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            student.namaLengkap,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'NIS: ${student.nis} | Kelas: ${student.namaKelas}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  final studentProvider =
                                      Provider.of<StudentProvider>(
                                        context,
                                        listen: false,
                                      );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ChangeNotifierProvider.value(
                                          value: studentProvider,
                                          child: EditStudentScreen(
                                            student: student,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _showDeleteConfirmation(
                                      context,
                                      student,
                                    ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        StudentDetailScreen(student: student),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
