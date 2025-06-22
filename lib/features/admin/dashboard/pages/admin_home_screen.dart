import 'package:e_absensi/features/admin/dashboard/widgets/attendance_monitoring_card.dart';
import 'package:e_absensi/features/admin/dashboard/widgets/dashboard_header.dart';
import 'package:e_absensi/features/admin/dashboard/widgets/quick_actions_card.dart';
import 'package:e_absensi/features/admin/dashboard/widgets/spp_monitoring_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/features/shared/widgets/bottom_navbar.dart';
import '../provider/dashboard_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()..fetchDashboardData(),
      child: const _AdminHomeScreenContent(),
    );
  }
}

class _AdminHomeScreenContent extends StatelessWidget {
  const _AdminHomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final currentIndex = getNavIndex(adminRole, currentPath);
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardProvider>().fetchDashboardData(),
          color: const Color(0xFF2196F3),
          child: Container(
            width: double.infinity,
            height: double.infinity,
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
                  const DashboardHeader(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: provider.isLoading && provider.totalStudents == 0
                      ? const _LoadingState() 
                      : provider.error != null
                        ? _ErrorState(message: provider.error!, onRetry: () => context.read<DashboardProvider>().fetchDashboardData())
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AttendanceMonitoringCard(),
                            SizedBox(height: 24),
                            SppMonitoringCard(),
                            SizedBox(height: 24),
                            AdminQuickActions(),
                            SizedBox(height: 100),
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
}

// =================================================================
// WIDGET-WIDGET UI INTERNAL
// =================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          SizedBox(height: 16),
          Text('Memuat data dashboard...', style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({Key? key, required this.message, required this.onRetry}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            const Text('Gagal Memuat Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}