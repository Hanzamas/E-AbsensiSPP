import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/student_attendance_provider.dart';

class ScheduleTab extends StatefulWidget {
  final StudentAttendanceProvider provider;

  const ScheduleTab({super.key, required this.provider});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  // ✅ Fix: Initialize as nullable, set in initState
  String? _selectedDay;
  
  // ✅ Remove "Hari Ini" - langsung list hari
  final List<Map<String, String>> _days = [
    {'label': 'Senin', 'value': 'senin'},
    {'label': 'Selasa', 'value': 'selasa'},
    {'label': 'Rabu', 'value': 'rabu'},
    {'label': 'Kamis', 'value': 'kamis'},
    {'label': 'Jumat', 'value': 'jumat'},
    {'label': 'Sabtu', 'value': 'sabtu'},
    {'label': 'Minggu', 'value': 'minggu'},
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Set default day in initState
    _selectedDay = _getCurrentDay();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day Selector
        _buildDaySelector(),
        
        // Schedule Content
        Expanded(child: _buildScheduleContent()),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today, 
                  color: Color(0xFF2196F3), 
                  size: 20
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pilih Hari',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _days.map((day) => _buildDayChip(day['label']!, day['value']!)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(String label, String value) {
    // ✅ Check for null safety
    final isSelected = _selectedDay == value;
    final isToday = value == _getCurrentDay();
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDay = value;
          });
          _loadScheduleForDay(value);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF2196F3) 
                : isToday 
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF2196F3)
                  : isToday 
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE2E8F0),
              width: isToday ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isToday && !isSelected) ...[
                const Icon(
                  Icons.today,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : isToday 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    // ✅ Check if _selectedDay is null
    if (_selectedDay == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
      );
    }

    if (widget.provider.isLoadingSchedule) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
      );
    }

    // ✅ Filter schedule untuk hari yang dipilih
    final daySchedules = _getSchedulesForSelectedDay();

    if (daySchedules.isEmpty) {
      return _buildEmptySchedule();
    }

    return RefreshIndicator(
      onRefresh: () => widget.provider.loadSchedules(),
      color: const Color(0xFF2196F3),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daySchedules.length,
        itemBuilder: (context, index) {
          final schedule = daySchedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule) {
    // ✅ Null safety check
    if (_selectedDay == null) return const SizedBox.shrink();
    
    // ✅ Check if selected day is today
    final isToday = _selectedDay == _getCurrentDay();
    final attendanceStatus = isToday 
        ? widget.provider.getAttendanceStatusForSchedule(schedule)
        : 'Tidak Tersedia';
    final statusColor = _getStatusColor(attendanceStatus);
    final canScan = isToday && _canScanQR(schedule);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.mapel ?? 'Mata Pelajaran',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.guruPengajar ?? 'Guru Pengajar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Show status only for today
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(attendanceStatus), size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          attendanceStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Info detail
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.access_time,
                    'Waktu',
                    '${schedule.jamMulai} - ${schedule.jamSelesai}',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.room,
                    'Ruang',
                    schedule.ruangKelas ?? 'Ruang Kelas',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.people,
                    'Kapasitas',
                    '${schedule.kapasitas ?? 0} siswa',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.schedule,
                    'Hari',
                    _formatDay(schedule.hari ?? ''),
                  ),
                ),
              ],
            ),
            
            // ✅ Action buttons - HANYA untuk hari ini
            if (isToday) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // ✅ Scan button - hanya jika bisa scan
                  if (canScan)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scanQRForSchedule(schedule),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Scan Absensi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  
                  // ✅ Spacing jika ada scan button
                  if (canScan) const SizedBox(width: 12),
                  
                  // ✅ Detail button - selalu ada untuk hari ini
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showScheduleDetail(schedule),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Jadwal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada jadwal pelajaran untuk hari ${_formatDay(_selectedDay ?? '')}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Enhanced Schedule Detail Modal
  Widget _buildScheduleDetailModal(dynamic schedule) {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final isToday = _selectedDay == _getCurrentDay();
    final attendanceStatus = isToday 
        ? widget.provider.getAttendanceStatusForSchedule(schedule)
        : 'Tidak Tersedia';
    final statusColor = _getStatusColor(attendanceStatus);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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
                const Icon(Icons.info_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Detail Jadwal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Subject & Teacher
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        schedule.mapel ?? 'Mata Pelajaran',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        schedule.guruPengajar ?? 'Guru Pengajar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Schedule Details
                _buildDetailRow(
                  Icons.calendar_today, 
                  'Hari', 
                  _formatDay(schedule.hari ?? '')
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time, 
                  'Waktu', 
                  '${schedule.jamMulai} - ${schedule.jamSelesai}'
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.room, 
                  'Ruang Kelas', 
                  schedule.ruangKelas ?? 'Tidak diketahui'
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.people, 
                  'Kapasitas', 
                  '${schedule.kapasitas ?? 0} siswa'
                ),
                
                // ✅ Status - hanya untuk hari ini
                if (isToday) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    _getStatusIcon(attendanceStatus), 
                    'Status Absensi', 
                    attendanceStatus,
                    valueColor: statusColor,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // ✅ Action buttons untuk hari ini
                if (isToday) ...[
                  Row(
                    children: [
                      if (_canScanQR(schedule)) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _scanQRForSchedule(schedule);
                            },
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Scan Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Tutup'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Untuk hari lain, hanya tombol tutup
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? const Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  List<dynamic> _getSchedulesForSelectedDay() {
    if (_selectedDay == null) return [];
    return widget.provider.schedules.where((s) => s.hari.toLowerCase() == _selectedDay).toList();
  }

  // ✅ Get current day - static method
  String _getCurrentDay() {
    final today = DateTime.now().weekday;
    const days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];
    return days[today - 1];
  }

  String _getAttendanceStatusForSchedule(dynamic schedule) {
    return widget.provider.getAttendanceStatusForSchedule(schedule);
  }

  // ✅ Can scan - dengan time validation
  bool _canScanQR(dynamic schedule) {
    final status = _getAttendanceStatusForSchedule(schedule);
    if (status != 'Belum Absen') return false;
    
    final now = DateTime.now();
    
    try {
      // Parse jam mulai dan selesai
      final startTimeParts = schedule.jamMulai.split(':');
      final endTimeParts = schedule.jamSelesai.split(':');
      
      final startTime = DateTime(
        now.year, now.month, now.day,
        int.parse(startTimeParts[0]), int.parse(startTimeParts[1])
      );
      
      final endTime = DateTime(
        now.year, now.month, now.day,
        int.parse(endTimeParts[0]), int.parse(endTimeParts[1])
      );
      
      // Bisa scan jika waktu dalam rentang jadwal (dengan toleransi 15 menit sebelum mulai)
      final scanStartTime = startTime.subtract(const Duration(minutes: 15));
      return now.isAfter(scanStartTime) && now.isBefore(endTime);
    } catch (e) {
      return false;
    }
  }

  void _loadScheduleForDay(String day) {
    widget.provider.loadSchedules();
  }

  void _scanQRForSchedule(dynamic schedule) {
    Navigator.pushNamed(context, '/student/attendance/scan');
  }

  void _showScheduleDetail(dynamic schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScheduleDetailModal(schedule),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return const Color(0xFF10B981);
      case 'alpha': return const Color(0xFFEF4444);
      case 'belum absen': return const Color(0xFFF59E0B);
      case 'sakit': return const Color(0xFF8B5CF6);
      case 'izin': return const Color(0xFF8B5CF6);
      case 'tidak tersedia': return Colors.grey.shade500;
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return Icons.check_circle;
      case 'alpha': return Icons.cancel;
      case 'belum absen': return Icons.schedule;
      case 'sakit': return Icons.sick;
      case 'izin': return Icons.event_busy;
      case 'tidak tersedia': return Icons.block;
      default: return Icons.help_outline;
    }
  }

  String _formatDay(String day) {
    const dayMap = {
      'senin': 'Senin',
      'selasa': 'Selasa',
      'rabu': 'Rabu',
      'kamis': 'Kamis',
      'jumat': 'Jumat',
      'sabtu': 'Sabtu',
      'minggu': 'Minggu',
    };
    return dayMap[day.toLowerCase()] ?? day;
  }
}