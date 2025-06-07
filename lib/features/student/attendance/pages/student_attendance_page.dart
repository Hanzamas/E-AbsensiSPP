import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/student_attendance_provider.dart';
import '../widgets/attendance_history_tab.dart';
import '../widgets/schedule_tab.dart';
import '../widgets/statistics_tab.dart';
import '../widgets/scan_qr_tab.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../student/dashboard/provider/student_dashboard_provider.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StudentAttendanceProvider>(context, listen: false);
      provider.loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // ✅ AppBar SAMA dengan Teacher - ukuran dan style konsisten
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
                Icons.assignment_ind,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Absensi',
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
        automaticallyImplyLeading: false, // ✅ Hilangkan back button
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          tabs: const [
            Tab(text: 'Riwayat'),
            Tab(text: 'Jadwal'),
            Tab(text: 'Statistik'),
            Tab(text: 'Scan QR'),
          ],
        ),
      ),
      body: Consumer<StudentAttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              AttendanceHistoryTab(provider: provider),
              ScheduleTab(provider: provider),
              StatisticsTab(provider: provider),
              ScanQRTab(provider: provider),
            ],
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final dashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
          final userRole = dashboardProvider.userProfile?.role?.toLowerCase() ?? 'siswa';

          return CustomBottomNavBar(
            currentIndex: 1,
            userRole: userRole,
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(StudentAttendanceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadInitialData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
}