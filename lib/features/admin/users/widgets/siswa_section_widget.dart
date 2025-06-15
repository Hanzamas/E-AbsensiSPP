import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/student/add_student_screen.dart';
import '../pages/student/student_list_screen.dart';
import '../provider/student_provider.dart';
import 'quick_action_card.dart';

class SiswaSectionWidget extends StatelessWidget {
  const SiswaSectionWidget({Key? key}) : super(key: key);

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kelola Siswa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'Tambah Siswa',
                    subtitle: 'Daftarkan Siswa Baru',
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => StudentProvider(),
                            child: const AddStudentScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'Daftar Siswa',
                    subtitle: 'Lihat & Edit Data Siswa',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => StudentProvider(),
                            child: const StudentListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}