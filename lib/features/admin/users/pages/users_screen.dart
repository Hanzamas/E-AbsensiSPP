import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/features/shared/widgets/bottom_navbar.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/siswa_section_widget.dart';
import '../widgets/guru_section_widget.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = false;
  String? _error;
  bool _isDownloading = false;

  Future<void> _refreshData() async {
    print('Refreshing Users data...');
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _error = null;
    });
  }

  void _onDownloadStateChanged(bool isDownloading) {
    setState(() {
      _isDownloading = isDownloading;
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
                Icons.people_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kelola Users',
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF2196F3),
                  ),
                ),
              )
            : _error != null
                ? ErrorStateWidget(
                    message: _error!,
                    onRetry: _refreshData,
                  )
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
                            const HeaderWidget(),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SiswaSectionWidget(),
                                  const SizedBox(height: 24),
                                  GuruSectionWidget(
                                    isDownloading: _isDownloading,
                                    onDownloadStateChanged: _onDownloadStateChanged,
                                  ),
                                  const SizedBox(height: 24),
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