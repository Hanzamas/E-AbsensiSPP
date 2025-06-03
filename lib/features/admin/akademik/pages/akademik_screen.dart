import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:e_absensi/features/shared/widgets/bottom_navbar.dart'; // Import CustomBottomNavBar
import 'package:e_absensi/features/admin/akademik/pages/class_list_screen.dart'; // Import ClassListScreen
import 'package:e_absensi/features/admin/akademik/pages/add_class_screen.dart';
import 'package:provider/provider.dart';
import '../provider/class_provider.dart';

class AdminAkademikScreen extends StatefulWidget {
  const AdminAkademikScreen({Key? key}) : super(key: key);

  @override
  _AdminAkademikScreenState createState() => _AdminAkademikScreenState();
}

class _AdminAkademikScreenState extends State<AdminAkademikScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _refreshData() async {
    print('Refreshing Akademik data...');
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final currentIndex = getNavIndex(adminRole, currentPath);

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
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kelola Akademik',
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              )
            : _error != null
                ? _buildErrorState(_error!)
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF2196F3),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                          stops: [0.0, 0.8],
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildKelasSection(),
                                  const SizedBox(height: 24),
                                  _buildMapelSection(),
                                  const SizedBox(height: 24),
                                  _buildAssignGuruSection(),
                                  const SizedBox(height: 24),
                                  _buildTahunAjaranSection(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        userRole: adminRole,
        context: context,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola Data Akademik Sekolah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasSection() {
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
                    Icons.class_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kelola Kelas',
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
                  child: _QuickActionCard(
                    title: 'Tambah Kelas',
                    subtitle: 'Buat Kelas Baru',
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      print('Tambah Kelas tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddClassScreen(),
                        ),
                      ).then((success) {
                        if (success == true) {
                          // Refresh the class list if a new class was added
                          Provider.of<ClassProvider>(context, listen: false).loadClasses();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Daftar Kelas',
                    subtitle: 'Lihat & Edit Kelas',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      print('Daftar Kelas tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClassListScreen(),
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

  Widget _buildMapelSection() {
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
                    Icons.book_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kelola Mata Pelajaran',
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
                  child: _QuickActionCard(
                    title: 'Tambah Mapel',
                    subtitle: 'Buat Mapel Baru',
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      print('Tambah Mapel tapped');
                      // TODO: Navigate to add subject page
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Daftar Mapel',
                    subtitle: 'Lihat & Edit Mapel',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      print('Daftar Mapel tapped');
                      // TODO: Navigate to subject list page
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

  Widget _buildAssignGuruSection() {
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
                    Icons.assignment_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Assign Guru ke Kelas',
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
                  child: _QuickActionCard(
                    title: 'Assign Guru',
                    subtitle: 'Atur Pengajaran Guru',
                    icon: Icons.assignment_ind_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      print('Assign Guru tapped');
                      // TODO: Navigate to assign teacher page
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Daftar Pengajaran',
                    subtitle: 'Lihat & Edit Pengajaran',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      print('Daftar Pengajaran tapped');
                      // TODO: Navigate to teaching list page
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

  Widget _buildTahunAjaranSection() {
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
                    Icons.calendar_today_rounded,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kelola Tahun Ajaran',
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
                  child: _QuickActionCard(
                    title: 'Tambah Tahun Ajaran',
                    subtitle: 'Buat Tahun Ajaran Baru',
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      print('Tambah Tahun Ajaran tapped');
                      // TODO: Navigate to add academic year page
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Daftar Tahun Ajaran',
                    subtitle: 'Lihat & Edit Tahun Ajaran',
                    icon: Icons.list_alt,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      print('Daftar Tahun Ajaran tapped');
                      // TODO: Navigate to academic year list page
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 