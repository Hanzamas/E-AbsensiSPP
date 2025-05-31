import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/teacher_attendance_provider.dart';

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({super.key});

  @override
  State<TeacherAttendancePage> createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherAttendanceProvider>().loadAllData();
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
      appBar: AppBar(
        title: const Text(
          'Absensi Guru',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Jadwal'),
            Tab(text: 'Riwayat'),
            Tab(text: 'QR Code'),
          ],
        ),
      ),
      body: Consumer<TeacherAttendanceProvider>(
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
              _ScheduleTab(provider: provider),
              _HistoryTab(provider: provider),
              _QRCodeTab(provider: provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(TeacherAttendanceProvider provider) {
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
              onPressed: () => provider.refreshData(),
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

// Schedule Tab
class _ScheduleTab extends StatelessWidget {
  final TeacherAttendanceProvider provider;

  const _ScheduleTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Card
            _buildStatsCard(),
            const SizedBox(height: 24),
            
            // Today's Schedule
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            if (provider.todaySchedule.isNotEmpty)
              ...provider.todaySchedule.map((schedule) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _ScheduleCard(
                    schedule: schedule,
                    onStartSession: () => _startSession(context, schedule.id),
                    isStartingSession: provider.isCreatingSession,
                  ),
                );
              })
            else
              const _EmptyStateCard(
                icon: Icons.calendar_today_outlined,
                title: 'Tidak Ada Kelas Hari Ini',
                subtitle: 'Anda tidak memiliki jadwal mengajar hari ini',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Hari Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Siswa',
                  value: '${provider.totalStudents}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Hadir',
                  value: '${provider.presentToday}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Alpha',
                  value: '${provider.absentToday}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Kehadiran',
                  value: provider.attendanceRateText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startSession(BuildContext context, int idPengajaran) async {
    final success = await provider.createLearningSession(idPengajaran);
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi pembelajaran berhasil dimulai'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
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
}

// History Tab
class _HistoryTab extends StatelessWidget {
  final TeacherAttendanceProvider provider;

  const _HistoryTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDatePicker(context),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    provider.selectedDate != null
                        ? _formatDate(provider.selectedDate!)
                        : 'Pilih Tanggal',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.selectedDate != null
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300],
                    foregroundColor: provider.selectedDate != null
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: provider.selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Hadir', 'Alpha', 'Sakit', 'Izin']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) => provider.setStatusFilter(value),
                ),
              ),
            ],
          ),
        ),
        
        // Attendance List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: provider.filteredAttendance.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.filteredAttendance.length,
                    itemBuilder: (context, index) {
                      final record = provider.filteredAttendance[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _AttendanceCard(
                          record: record,
                          onTap: () => context.push('/teacher/attendance/detail/${record.idAbsensi}'),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('Tidak ada data absensi'),
                  ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      provider.setDateFilter(date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// QR Code Tab
class _QRCodeTab extends StatelessWidget {
  final TeacherAttendanceProvider provider;

  const _QRCodeTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.hasActiveSession)
              _buildActiveSessionCard()
            else
              _buildNoActiveSessionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard() {
    final session = provider.activeSession!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code,
            color: Color(0xFF4CAF50),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sesi Aktif',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'QR Token: ${session.qrToken}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveSessionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Sesi Aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai sesi pembelajaran di tab Jadwal untuk mendapatkan QR token',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Reusable Components
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback? onStartSession;
  final bool isStartingSession;

  const _ScheduleCard({
    required this.schedule,
    this.onStartSession,
    required this.isStartingSession,
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule.namaMapel ?? 'Mata Pelajaran',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${schedule.namaKelas} • ${schedule.jamMulai} - ${schedule.jamSelesai}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          if (onStartSession != null) ...[
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

class _AttendanceCard extends StatelessWidget {
  final dynamic record;
  final VoidCallback onTap;

  const _AttendanceCard({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.namaSiswa ?? 'Nama Siswa',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${record.namaMapel} - ${record.namaKelas}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(status: record.status ?? 'Alpha'),
                const Spacer(),
                Text(
                  record.formattedDate ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'hadir':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF4CAF50);
        break;
      case 'alpha':
        backgroundColor = const Color(0xFFFED7D7);
        textColor = const Color(0xFFE53E3E);
        break;
      case 'sakit':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case 'izin':
        backgroundColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF9C27B0);
        break;
      default:
        backgroundColor = const Color(0xFFF7FAFC);
        textColor = const Color(0xFF718096);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

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
            color: Colors.black.withValues(alpha: 0.04),
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