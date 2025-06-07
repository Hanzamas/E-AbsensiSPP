import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/student_attendance_provider.dart';

class AttendanceHistoryTab extends StatefulWidget {
  final StudentAttendanceProvider provider;

  const AttendanceHistoryTab({
    super.key,
    required this.provider,
  });

  @override
  State<AttendanceHistoryTab> createState() => _AttendanceHistoryTabState();
}

class _AttendanceHistoryTabState extends State<AttendanceHistoryTab> {
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.provider.loadAttendanceHistory(),
      color: const Color(0xFF2196F3),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Section - SAMA dengan dashboard card
            _buildFilterSection(),
            const SizedBox(height: 16),
            
            // Quick Stats - SAMA dengan dashboard card
            _buildQuickStats(),
            const SizedBox(height: 16),
            
            // Attendance List
            _buildAttendanceList(),
            const SizedBox(height: 100), // Space for bottom navbar
          ],
        ),
      ),
    );
  }

  // ✅ Filter Section dengan design SAMA seperti dashboard
  Widget _buildFilterSection() {
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
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Filter & Export',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        trailing: Icon(
          _isFilterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: const Color(0xFF64748B),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isFilterExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dropdown Filters
                Column(
                  children: [
                    _buildSubjectDropdown(),
                    const SizedBox(height: 12),
                    _buildStatusDropdown(),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Date Range Picker
                _buildDateRangePicker(),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Terapkan Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Export Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.provider.isDownloading ? null : _downloadExcel,
                    icon: widget.provider.isDownloading 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(widget.provider.isDownloading ? 'Downloading...' : 'Download Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Stats Cards dengan design SAMA seperti dashboard
  Widget _buildQuickStats() {
    final stats = widget.provider.getAttendanceStats();
    
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
        padding: const EdgeInsets.all(16),
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
                    Icons.analytics,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kehadiran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total',
                    value: '${stats['total'] ?? 0}',
                    color: const Color(0xFF718096),
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Hadir',
                    value: '${stats['hadir'] ?? 0}',
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Alpha',
                    value: '${stats['alpha'] ?? 0}',
                    color: const Color(0xFFE53E3E),
                    icon: Icons.cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'S/I',
                    value: '${(stats['sakit'] ?? 0) + (stats['izin'] ?? 0)}',
                    color: const Color(0xFFFF9800),
                    icon: Icons.healing,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (widget.provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.provider.attendanceHistory.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: widget.provider.attendanceHistory.map((attendance) {
        return _buildAttendanceCard(attendance);
      }).toList(),
    );
  }

  // ✅ Attendance Card dengan design SAMA seperti dashboard
  Widget _buildAttendanceCard(dynamic attendance) {
    final status = attendance.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(status), size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(attendance.tanggal),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              attendance.namaMapel ?? 'Mata Pelajaran',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  '${attendance.jamMulai} - ${attendance.jamSelesai}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.class_, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    attendance.namaKelas ?? 'Kelas',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            if (attendance.waktuScan != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 16, color: Color(0xFF2196F3)),
                    const SizedBox(width: 8),
                    Text(
                      'Scan: ${_formatTime(attendance.waktuScan)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (attendance.keterangan != null && 
                attendance.keterangan != '-' && 
                attendance.keterangan.toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Keterangan: ${attendance.keterangan}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Absensi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data absensi akan muncul setelah Anda melakukan scan QR',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods tetap sama...
  Widget _buildSubjectDropdown() {
    final subjects = widget.provider.getAvailableSubjects();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.provider.selectedMapel,
        decoration: const InputDecoration(
          labelText: 'Mata Pelajaran',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Semua Mata Pelajaran'),
          ),
          ...subjects.map((subject) => DropdownMenuItem<String>(
            value: subject,
            child: Text(subject),
          )),
        ],
        onChanged: (value) {
          widget.provider.setMapelFilter(value);
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    const statuses = ['Hadir', 'Alpha', 'Sakit', 'Izin'];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.provider.selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Semua Status'),
          ),
          ...statuses.map((status) => DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          )),
        ],
        onChanged: (value) {
          widget.provider.setStatusFilter(value);
        },
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Text(
              _getDateRangeText(),
              style: TextStyle(
                fontSize: 14,
                color: widget.provider.startDate != null 
                    ? const Color(0xFF1E293B)
                    : Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _applyFilters() {
    widget.provider.applyFilters();
  }

  void _resetFilters() {
    widget.provider.clearFilters();
  }

  // ✅ IMPROVED: Better download handling with user feedback
  Future<void> _downloadExcel() async {
    try {
      // ✅ Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Mengunduh file excel...'),
            ],
          ),
        ),
      );

      final filePath = await widget.provider.downloadExcel();
      
      // ✅ Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (!mounted) return;
      
      if (filePath != null) {
        // ✅ Success message with file location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('File berhasil diunduh!'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Lokasi: ${filePath.split('/').last}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        // ✅ Error with provider error message
        final errorMessage = widget.provider.error ?? 'Gagal download file';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'COBA LAGI',
              textColor: Colors.white,
              onPressed: () => _downloadExcel(),
            ),
          ),
        );
      }
    } catch (e) {
      // ✅ Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.provider.startDate != null && widget.provider.endDate != null
          ? DateTimeRange(start: widget.provider.startDate!, end: widget.provider.endDate!)
          : null,
    );

    if (picked != null) {
      widget.provider.setDateRange(picked.start, picked.end);
    }
  }

  String _getDateRangeText() {
    if (widget.provider.startDate != null && widget.provider.endDate != null) {
      final start = DateFormat('dd MMM yyyy').format(widget.provider.startDate!);
      final end = DateFormat('dd MMM yyyy').format(widget.provider.endDate!);
      return '$start - $end';
    }
    return 'Pilih rentang tanggal';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return const Color(0xFF4CAF50);
      case 'alpha': return const Color(0xFFE53E3E);
      case 'sakit': return const Color(0xFFF59E0B);
      case 'izin': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return Icons.check_circle;
      case 'alpha': return Icons.cancel;
      case 'sakit': return Icons.sick;
      case 'izin': return Icons.event_busy;
      default: return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(time);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return time;
    }
  }
}

// ✅ StatCard Component SAMA dengan dashboard
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}