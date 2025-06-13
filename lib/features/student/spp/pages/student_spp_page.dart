import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/student_spp_provider.dart';
import '../widgets/spp_summary_tab.dart';
import '../widgets/spp_history_tab.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../dashboard/provider/student_dashboard_provider.dart';

class StudentSppPage extends StatefulWidget {
  const StudentSppPage({Key? key}) : super(key: key);

  @override
  State<StudentSppPage> createState() => _StudentSppPageState();
}

class _StudentSppPageState extends State<StudentSppPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedIndex = 2; // SPP tab index in bottom nav

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentSppProvider>().loadInitialData();
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
      backgroundColor: const Color(0xFFF8F9FA), // ✅ SAMA dengan attendance
      // ✅ AppBar SAMA PERSIS dengan Attendance - struktur identik
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
                Icons.payment_rounded, // ✅ SPP icon
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SPP', // ✅ Cukup "SPP" saja
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3), // ✅ SAMA warna
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ Hilangkan back button
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // ✅ SAMA dengan attendance
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelPadding: const EdgeInsets.symmetric(horizontal: 5.0), // ✅ SAMA padding
          tabs: const [
            Tab(text: 'Tagihan'), // ✅ Tanpa icon, hanya text
            Tab(text: 'Riwayat'), // ✅ Tanpa icon, hanya text
          ],
        ),
      ),
      
      // ✅ Body dengan Consumer - SAMA struktur dengan attendance
      body: Consumer<StudentSppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBills || provider.isLoadingHistory) {
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
              SppSummaryTab(provider: provider),
              SppHistoryTab(provider: provider),
            ],
          );
        },
      ),
      
      // ✅ Bottom navigation - SAMA dengan attendance
      bottomNavigationBar: Builder(
        builder: (context) {
          final dashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
          final userRole = dashboardProvider.userProfile?.role?.toLowerCase() ?? 'siswa';

          return CustomBottomNavBar(
            currentIndex: _selectedIndex,
            userRole: userRole,
            context: context,
          );
        },
      ),
    );
  }

  // ✅ Error state - SAMA PERSIS dengan attendance
  Widget _buildErrorState(StudentSppProvider provider) {
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