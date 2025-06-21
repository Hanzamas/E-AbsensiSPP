import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/features/admin/users/widgets/quick_action_card.dart';

class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({Key? key}) : super(key: key);

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
                offset: const Offset(0, 4))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.apps, color: Color(0xFF2196F3), size: 20)),
              const SizedBox(width: 12),
              const Text('Menu Cepat Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: QuickActionCard(
                      title: 'Kelola Users',
                      subtitle: 'Tambah & Atur Pengguna',
                      icon: Icons.people_alt,
                      color: const Color(0xFF2196F3),
                      onTap: () => context.go('/admin/users'))),
              const SizedBox(width: 16),
              Expanded(
                  child: QuickActionCard(
                      title: 'Kelola Akademik',
                      subtitle: 'Kelas, Mapel, Tahun Ajaran',
                      icon: Icons.school,
                      color: const Color(0xFF4CAF50),
                      onTap: () => context.go('/admin/akademik'))),
            ]),
          ],
        ),
      ),
    );
  }
}