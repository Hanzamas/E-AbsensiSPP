import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../provider/student_attendance_provider.dart';

class ScanQRTab extends StatefulWidget {
  final StudentAttendanceProvider provider;

  const ScanQRTab({super.key, required this.provider});

  @override
  State<ScanQRTab> createState() => _ScanQRTabState();
}

class _ScanQRTabState extends State<ScanQRTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ❌ REMOVE: Quick Actions - dihapus sesuai permintaan
          
          // Scan QR Card - tetap ada
          _buildScanQRCard(context),
          const SizedBox(height: 16),
          
          // Today's Schedule with Scan Status
          _buildTodaySchedule(),
          const SizedBox(height: 16),
          
          // Recent Scan History
          _buildRecentScanHistory(),
        ],
      ),
    );
  }

  // ❌ REMOVE: _buildQuickActions method - dihapus
  
  // ❌ REMOVE: _buildQuickActionButton method - dihapus

  Widget _buildScanQRCard(BuildContext context) {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'pagi' : now.hour < 15 ? 'siang' : now.hour < 18 ? 'sore' : 'malam';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Time greeting
          Text(
            'Selamat $timeOfDay! 👋',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          
          // QR Scanner Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Scan QR Code untuk Absensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arahkan kamera ke QR Code yang ditampilkan guru',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // ✅ Scan Button - tetap menggunakan page yang sudah ada
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.provider.isScanning ? null : () {
                // ✅ Tetap pakai page yang sudah ada
                context.go('/student/attendance/scan');
              },
              icon: widget.provider.isScanning 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    )
                  : const Icon(Icons.qr_code_scanner, size: 20),
              label: Text(widget.provider.isScanning ? 'Memproses...' : 'Mulai Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final todaySchedules = widget.provider.getSchedulesForDay('today');
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: const Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Jadwal Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                '${todaySchedules.length} kelas',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (todaySchedules.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '🏖️ Tidak ada jadwal hari ini',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            Column(
              children: todaySchedules.take(3).map((schedule) {
                return _buildScheduleWithScanStatus(schedule);
              }).toList(),
            ),
          
          if (todaySchedules.length > 3) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _showAllSchedules(),
              child: Text('Lihat ${todaySchedules.length - 3} jadwal lainnya'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleWithScanStatus(dynamic schedule) {
    final status = widget.provider.getAttendanceStatusForSchedule(schedule);
    final canScan = widget.provider.canScanQRForSchedule(schedule);
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Time
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  schedule.jamMulai.substring(0, 5),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  schedule.jamSelesai.substring(0, 5),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.mapel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${schedule.ruangKelas} • ${schedule.guruPengajar}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Status & Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              
              if (canScan) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _scanForSchedule(schedule),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanHistory() {
    final recentScans = widget.provider.attendanceHistory
        .where((a) => a.waktuScan != null)
        .take(5)
        .toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: const Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Riwayat Scan Terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (recentScans.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '🔍 Belum ada riwayat scan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            Column(
              children: recentScans.map((attendance) {
                return _buildScanHistoryItem(attendance);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildScanHistoryItem(dynamic attendance) {
    final statusColor = _getStatusColor(attendance.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.namaMapel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${attendance.tanggal.day} ${_getMonthName(attendance.tanggal.month)}, ${_formatTime(attendance.waktuScan)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              attendance.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return const Color(0xFF10B981);
      case 'alpha': return const Color(0xFFEF4444);
      case 'belum absen': return const Color(0xFFF59E0B);
      case 'sakit': return const Color(0xFF8B5CF6);
      case 'izin': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  void _scanForSchedule(dynamic schedule) {
    // ✅ Tetap pakai page scan yang sudah ada
    context.go('/student/attendance/scan');
  }

  void _showAllSchedules() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScheduleModal(),
    );
  }

  Widget _buildScheduleModal() {
    final todaySchedules = widget.provider.getSchedulesForDay('today');
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Jadwal Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todaySchedules.length,
              itemBuilder: (context, index) {
                return _buildScheduleWithScanStatus(todaySchedules[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}