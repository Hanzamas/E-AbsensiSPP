import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/features/shared/widgets/bottom_navbar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // TODO: Add data loading logic here later
  bool _isLoading = false; // Placeholder loading state
  String? _error; // Placeholder error state

  // Placeholder method for refreshing data
  Future<void> _refreshData() async {
    // TODO: Implement data refresh logic
    print('Refreshing Admin Home data...');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() {
      _error = null; // Clear error on refresh attempt
      // Update data here if loaded successfully
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
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
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
        child: _isLoading // Check loading state
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
                            _buildAdminHeader(),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTotalAttendanceMonitoring(),
                                  const SizedBox(height: 24),
                                  _buildTotalSppMonitoring(),
                                  const SizedBox(height: 24),
                                  _buildAdminQuickActions(),
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

  // Adapted Error State Widget
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
              onPressed: _refreshData, // Use local refresh method
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

  // Adapted Header Widget
  Widget _buildAdminHeader() {
    // TODO: Fetch actual admin name/info
    const adminName = 'Administrator'; // Placeholder
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), // Same padding style
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Halo, ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: adminName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selamat datang di Dashboard Admin',
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

  // Implementation for Total Attendance Monitoring
  Widget _buildTotalAttendanceMonitoring() {
    // TODO: Fetch actual total attendance data for all students
    // Placeholder data
    const totalStudents = '100';
    const totalPresent = '90';
    const totalAlpha = '10'; // Changed from totalAbsent to totalAlpha for clarity based on OCR
    const totalSickIzin = '5';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // Same as teacher dashboard
        borderRadius: BorderRadius.circular(16), // Same radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Same shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Same padding
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
                    Icons.bar_chart,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Monitoring Absensi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Implement download attendance report
                    print('Download attendance report');
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF2196F3),
                  ),
                  tooltip: 'Download Laporan Absensi',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Using _StatCard for displaying key attendance numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Siswa',
                    value: totalStudents,
                    color: const Color(0xFF718096),
                    icon: Icons.people,
                    titleFontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Hadir',
                    value: totalPresent,
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle,
                    titleFontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Alpha',
                    value: totalAlpha,
                    color: const Color(0xFFE53E3E),
                    icon: Icons.cancel,
                    titleFontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Sakit/Izin',
                    value: totalSickIzin,
                    color: const Color(0xFFFF9800),
                    icon: Icons.healing,
                    titleFontSize: 10,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Implementation for Total SPP Monitoring
  Widget _buildTotalSppMonitoring() {
    // TODO: Fetch actual total SPP data for all students
    // Placeholder data
    const totalStudentsSPP = '100';
    const totalPaid = '80';
    const totalUnpaid = '20';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // Same as teacher dashboard
        borderRadius: BorderRadius.circular(16), // Same radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Same shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Same padding
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
                    Icons.credit_card,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Monitoring SPP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Implement download SPP report
                    print('Download SPP report');
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF2196F3),
                  ),
                  tooltip: 'Download Laporan SPP',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Using _StatCard for displaying key SPP numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Siswa',
                    value: totalStudentsSPP,
                    color: const Color(0xFF718096),
                    icon: Icons.people,
                    titleFontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Sudah Bayar',
                    value: totalPaid,
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle,
                    titleFontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Belum Bayar',
                    value: totalUnpaid,
                    color: const Color(0xFFE53E3E),
                    icon: Icons.cancel,
                    titleFontSize: 11,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Implementation for Admin Quick Actions
  Widget _buildAdminQuickActions() {
    return Container(
      width: double.infinity, // Take full width
      decoration: BoxDecoration(
        color: Colors.white, // Same as teacher dashboard
        borderRadius: BorderRadius.circular(16), // Same radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Same shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Same padding
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
                    Icons.apps,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menu Cepat Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Same spacing

            // Using _QuickActionCard for admin actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Kelola Users',
                    subtitle: 'Tambah & Atur Pengguna',
                    icon: Icons.people_alt,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      print('Kelola Users tapped');
                      context.go('/admin/users');
                    },
                  ),
                ),
                const SizedBox(width: 16), // Same spacing
                Expanded(
                  child: _QuickActionCard(
                    title: 'Kelola Akademik',
                    subtitle: 'Kelas, Mapel, Tahun Ajaran',
                    icon: Icons.school,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      print('Kelola Akademik tapped');
                      context.go('/admin/akademik');
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
} // Close _AdminHomeScreenState class here

// Adapted _StatCard Widget (copied locally)
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final double? titleFontSize;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Using withOpacity as seen in teacher code
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 11,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Adapted _QuickActionCard Widget (copied locally)
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

// The previous StatelessWidget AdminHomeScreen content is now part of this StatefulWidget.