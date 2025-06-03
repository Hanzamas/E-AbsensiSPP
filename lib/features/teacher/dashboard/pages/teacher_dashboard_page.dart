import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/teacher_dashboard_provider.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../data/model/schedule_model.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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
              'Dashboard',
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
              return _buildErrorState(provider);
            }

            return RefreshIndicator(
              onRefresh: () => provider.refreshData(),
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
                      _buildHeader(provider),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTodaySchedule(provider),
                            const SizedBox(height: 24),
                            _buildAttendanceStats(provider),
                            const SizedBox(height: 24),
                            _buildQuickActions(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // ✅ FIX: Dynamic role dari provider
      bottomNavigationBar: Consumer<TeacherDashboardProvider>(
        builder: (context, provider, _) {
          // Get role from user profile, fallback to 'guru'
          final userRole = provider.userProfile?.role?.toLowerCase() ?? 'guru';
          
          return CustomBottomNavBar(
            currentIndex: 0,
            userRole: userRole, // ✅ Dynamic role dari /users/my
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(TeacherDashboardProvider provider) {
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

  Widget _buildHeader(TeacherDashboardProvider provider) {
    final user = provider.userProfile;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                  text: user?.namaLengkap ?? 'Pak/Bu Guru',
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
            'Semoga hari mengajarmu menyenangkan dan bermanfaat',
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

Widget _buildAttendanceStats(TeacherDashboardProvider provider) {
  final stats = provider.attendanceStats;
  final todayClasses = provider.todayClasses;
  
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.analytics,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Statistik Kehadiran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              // Time period badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'Hari Ini',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Class filter dropdown
          if (todayClasses.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white, // Ubah warna background menjadi putih
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBDEFB)), // Border warna biru muda
              ),
              child: Theme(
                // Terapkan tema untuk dropdown yang muncul
                data: Theme.of(context).copyWith(
                  // Warna popup menu
                  canvasColor: Colors.white,
                  // Warna saat item dipilih
                  highlightColor: const Color(0xFFE3F2FD),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: provider.selectedClassId,
                    hint: const Text(
                      'Filter berdasarkan kelas',
                      style: TextStyle(color: Color(0xFF718096)),
                    ),
                    icon: const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Color(0xFF2196F3), // Ikon biru
                    ),
                    // Mengatur popup menu dengan border radius
                    menuMaxHeight: 300,
                    dropdownColor: Colors.white,
                    // Tambahkan border radius pada dropdown button
                    borderRadius: BorderRadius.circular(8),
                    // Styling untuk item yang dipilih
                    selectedItemBuilder: (context) {
                      return [
                        const Center(
                          child: Text(
                            'Semua Kelas',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ...todayClasses.map((classData) => Center(
                          child: Text(
                            '${classData.namaMapel} - ${classData.namaKelas}',
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ];
                    },
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua Kelas'),
                      ),
                      ...todayClasses.map((classData) => DropdownMenuItem<int?>(
                        value: classData.idKelas,
                        child: Text('${classData.namaMapel} - ${classData.namaKelas}'),
                      )),
                    ],
                    onChanged: (value) => provider.selectClass(value),
                    style: const TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          // Attendance rate progress bar
          if (stats['total'] != null && stats['total']! > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kehadiran Siswa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${((stats['hadir'] ?? 0) * 100 / (stats['total'] ?? 1)).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (stats['hadir'] ?? 0) / (stats['total'] ?? 1),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats['hadir'] == 0 ? Colors.grey : 
                  (stats['hadir']! / stats['total']!) > 0.75 ? 
                    const Color(0xFF4CAF50) : 
                    (stats['hadir']! / stats['total']!) > 0.5 ?
                      const Color(0xFFFFA000) :
                      const Color(0xFFF44336),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Memodifikasi bagian Row cards di widget _buildAttendanceStats
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 100, // Tetapkan tinggi yang sama untuk semua card
                  child: _StatCard(
                    title: 'Total',
                    value: '${stats['total'] ?? 0}',
                    color: const Color(0xFF718096),
                    icon: Icons.people,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 100, // Tetapkan tinggi yang sama untuk semua card
                  child: _StatCard(
                    title: 'Hadir',
                    value: '${stats['hadir'] ?? 0}',
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 100, // Tetapkan tinggi yang sama untuk semua card
                  child: _StatCard(
                    title: 'Alpha',
                    value: '${stats['alpha'] ?? 0}',
                    color: const Color(0xFFE53E3E),
                    icon: Icons.cancel,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 100, // Tetapkan tinggi yang sama untuk semua card
                  child: _StatCard(
                    title: 'S/I', // Ubah menjadi teks yang lebih singkat
                    value: '${(stats['sakit'] ?? 0) + (stats['izin'] ?? 0)}',
                    color: const Color(0xFFFF9800),
                    icon: Icons.healing,
                    // Hapus titleFontSize untuk menggunakan ukuran font yang sama
                  ),
                ),
              ),
            ],
          ),

          // Show selected class info if filter is active
          if (provider.selectedClassId != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    color: Color(0xFF2196F3),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menampilkan statistik untuk: ${_getSelectedClassInfo(provider)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => provider.selectClass(null),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF2196F3),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildTodaySchedule(TeacherDashboardProvider provider) {
  final todaySchedule = provider.todaySchedule;
  
  // Dapatkan waktu saat ini untuk menentukan jadwal yang sedang berlangsung
  final now = TimeOfDay.now();
  final currentTimeInMinutes = now.hour * 60 + now.minute;
  
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
          // Header dengan Icon dan Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kiri: Icon dan judul "Jadwal" saja
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Jadwal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  // Kanan: Badge "Hari Ini" dengan format hijau
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
              // Tombol "Lihat Semua" di bawah judul, di sebelah kiri, warna hitam
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft, // Ubah ke kiri (bukan kanan)
                child: TextButton(
                  onPressed: () => context.go('/teacher/attendance'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent, // Ubah warna menjadi hitam
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Lihat Semua'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Baris untuk Total Jadwal dan Status Indicators
          Row(
            children: [
              Text(
                'Total: ${todaySchedule.length} jadwal',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              // Compact status indicators di dalam SingleChildScrollView
              SizedBox(
                height: 20, // Batasi tinggi
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCompactStatusIndicator('Berlangsung', Colors.green),
                      const SizedBox(width: 5),
                      _buildCompactStatusIndicator('Akan Datang', Colors.orange),
                      const SizedBox(width: 5),
                      _buildCompactStatusIndicator('Selesai', Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Jadwal
          if (todaySchedule.isEmpty)
            _buildEmptySchedule()
          else
            ...todaySchedule.map((schedule) {
              final startTime = _timeToMinutes(schedule.jamMulai);
              final endTime = _timeToMinutes(schedule.jamSelesai);
              
              bool isOngoing = currentTimeInMinutes >= startTime && 
                              currentTimeInMinutes <= endTime;
              bool isPast = currentTimeInMinutes > endTime;
              bool isUpcoming = currentTimeInMinutes < startTime;
              
              return _buildCompactScheduleCard(
                schedule: schedule,
                isOngoing: isOngoing,
                isPast: isPast,
                isUpcoming: isUpcoming,
                context: context,
              );
            }),
        ],
      ),
    ),
  );
}
// Helper function untuk konversi waktu ke menit
int _timeToMinutes(String time) {
  final parts = time.split(':');
  if (parts.length >= 2) {
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
  return 0;
}

// Compact status indicator 
Widget _buildCompactStatusIndicator(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Kartu jadwal yang lebih compact
Widget _buildCompactScheduleCard({
  required ScheduleModel schedule,
  required bool isOngoing,
  required bool isPast,
  required bool isUpcoming,
  required BuildContext context,
}) {
  Color statusColor = isOngoing 
      ? const Color(0xFF4CAF50) 
      : (isUpcoming ? const Color(0xFFFF9800) : Colors.grey);
  String statusText = isOngoing ? 'Berlangsung' : (isUpcoming ? 'Akan Datang' : 'Selesai');
  
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor.withOpacity(0.3)),
    ),
    child: Stack(
      children: [
        // Status label di kanan atas
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ),
        
        // Konten jadwal
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.namaMapel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.namaKelas,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${_formatTime(schedule.jamMulai)} - ${_formatTime(schedule.jamSelesai)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.school,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          schedule.tahunAjaran,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatTime(String time) {
  // Format '07:00:00' menjadi '07:00'
  if (time.length >= 5) {
    return time.substring(0, 5);
  }
  return time;
}

  Widget _buildEmptySchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Kelas Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nikmati hari liburmu! 🎉',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
                    Icons.apps,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menu Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Absensi',
                    subtitle: 'Kelola Kehadiran',
                    icon: Icons.assignment_turned_in,
                    color: const Color(0xFF2196F3),
                    onTap: () => context.go('/teacher/attendance'), // ✅ FIX: Gunakan .go()
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Mulai Sesi',
                    subtitle: 'Buat QR Code',
                    icon: Icons.qr_code,
                    color: const Color(0xFF4CAF50),
                    onTap: () => context.go('/teacher/attendance'), // ✅ FIX: Gunakan .go()
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.namaMapel ?? 'Mata Pelajaran',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.namaKelas ?? 'Nama Kelas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.jamMulai} - ${schedule.jamSelesai}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
// Helper method to get selected class info
String _getSelectedClassInfo(TeacherDashboardProvider provider) {
  final selectedId = provider.selectedClassId;
  if (selectedId == null) return 'Semua Kelas';
  
  final selectedClass = provider.todayClasses.firstWhere(
    (c) => c.idKelas == selectedId,
    orElse: () => ScheduleModel(
      id: 0, idGuru: 0, idMapel: 0, idKelas: 0,
      hari: '', jamMulai: '', jamSelesai: '',
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
      namaGuru: '', namaMapel: '', namaKelas: '', tahunAjaran: '',
    ),
  );
  
  return selectedClass.id != 0 
    ? '${selectedClass.namaMapel} - ${selectedClass.namaKelas}'
    : 'Kelas tidak ditemukan';
}