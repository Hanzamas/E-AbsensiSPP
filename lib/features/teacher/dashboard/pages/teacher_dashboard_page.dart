import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/teacher_dashboard_provider.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<TeacherDashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFE53E3E),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF2D3748),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF718096)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.refreshData(),
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
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.refreshData(),
              color: const Color(0xFF2196F3),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(provider),
                    
                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Stats
                          _buildQuickStats(provider),
                          
                          const SizedBox(height: 24),
                          
                          // Today's Schedule
                          _buildTodaySchedule(provider),
                          
                          const SizedBox(height: 24),
                          
                          // Attendance Overview
                          _buildAttendanceOverview(provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(TeacherDashboardProvider provider) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.currentTimeGreeting,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.greetingName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelas Hari Ini',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${provider.todaySchedule.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tingkat Kehadiran',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            provider.attendanceRateText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(TeacherDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Absensi Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Siswa',
                value: '${provider.totalStudents}',
                icon: Icons.people_outline,
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Hadir',
                value: '${provider.presentToday}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4CAF50),
                bgColor: const Color(0xFFE8F5E8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Alpha',
                value: '${provider.absentToday}',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFE53E3E),
                bgColor: const Color(0xFFFED7D7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Sakit/Izin',
                value: '${provider.sickToday + provider.permissionToday}',
                icon: Icons.info_outline,
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(TeacherDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            if (provider.hasClassToday)
              Text(
                '${provider.todaySchedule.length} kelas',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (provider.hasClassToday)
          ...provider.todaySchedule.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            final isLast = index == provider.todaySchedule.length - 1;
            
            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _ScheduleCard(
                schedule: schedule,
                onStartSession: () => _startSession(provider, schedule.id),
                isStartingSession: provider.isStartingSession,
              ),
            );
          }).toList()
        else
          _EmptyStateCard(
            icon: Icons.calendar_today_outlined,
            title: 'Tidak Ada Kelas',
            subtitle: 'Anda tidak memiliki jadwal mengajar hari ini',
          ),
      ],
    );
  }

  Widget _buildAttendanceOverview(TeacherDashboardProvider provider) {
    if (provider.totalStudents == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Kehadiran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          
          // Attendance Rate Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tingkat Kehadiran',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.attendanceRateText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: provider.attendanceRate / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getAttendanceRateColor(provider.attendanceRate),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Breakdown
          Row(
            children: [
              Expanded(
                child: _AttendanceStatusItem(
                  label: 'Hadir',
                  count: provider.presentToday,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _AttendanceStatusItem(
                  label: 'Alpha',
                  count: provider.absentToday,
                  color: const Color(0xFFE53E3E),
                ),
              ),
              Expanded(
                child: _AttendanceStatusItem(
                  label: 'Sakit',
                  count: provider.sickToday,
                  color: const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _AttendanceStatusItem(
                  label: 'Izin',
                  count: provider.permissionToday,
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 80) return const Color(0xFF4CAF50);
    if (rate >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFE53E3E);
  }

  void _startSession(TeacherDashboardProvider provider, int idPengajaran) async {
    final success = await provider.startLearningSession(idPengajaran);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi pembelajaran berhasil dimulai'),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulai sesi: ${provider.error}'),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Stat Card Component
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}

// Schedule Card Component
class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback onStartSession;
  final bool isStartingSession;

  const _ScheduleCard({
    required this.schedule,
    required this.onStartSession,
    required this.isStartingSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isNow 
              ? const Color(0xFF4CAF50) 
              : Colors.grey.withOpacity(0.2),
          width: schedule.isNow ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: schedule.isNow 
                      ? const Color(0xFFE8F5E8) 
                      : const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  schedule.isNow ? Icons.play_circle : Icons.schedule,
                  color: schedule.isNow 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFF718096),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.classInfo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.formattedTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (schedule.isNow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Berlangsung',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          if (schedule.isNow) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isStartingSession ? null : onStartSession,
                icon: isStartingSession
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 18),
                label: Text(isStartingSession ? 'Memulai...' : 'Mulai Sesi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Empty State Card Component
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: const Color(0xFF718096),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}

// Attendance Status Item Component
class _AttendanceStatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _AttendanceStatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}