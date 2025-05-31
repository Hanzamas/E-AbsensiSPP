import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/teacher_attendance_provider.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String attendanceId;

  const AttendanceDetailPage({
    super.key,
    required this.attendanceId,
  });

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Detail Absensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showUpdateStatusDialog(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Consumer<TeacherAttendanceProvider>(
        builder: (context, provider, child) {
          final attendanceId = int.tryParse(widget.attendanceId);
          if (attendanceId == null) {
            return _buildErrorState('ID absensi tidak valid');
          }

          final record = provider.getFilteredAttendanceById(attendanceId);
          if (record == null) {
            return _buildErrorState('Data absensi tidak ditemukan');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentInfoCard(record),
                const SizedBox(height: 16),
                _buildAttendanceInfoCard(record),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isUpdatingAttendance 
                        ? null 
                        : () => _showUpdateStatusDialog(context),
                    icon: provider.isUpdatingAttendance
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.edit),
                    label: Text(
                      provider.isUpdatingAttendance 
                          ? 'Mengupdate...' 
                          : 'Update Status',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(dynamic record) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Informasi Siswa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Nama Siswa',
            value: record.namaSiswa, // Fixed: Removed ?? 'Tidak diketahui'
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'NIS',
            value: record.nis, // Fixed: Removed ?? 'Tidak diketahui'
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceInfoCard(dynamic record) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Informasi Absensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Mata Pelajaran',
            value: record.namaMapel,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Kelas',
            value: record.namaKelas,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Tanggal',
            value: record.formattedDate,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Status',
            value: record.status,
          ),
          if (record.keterangan != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Keterangan',
              value: record.keterangan!,
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    final provider = context.read<TeacherAttendanceProvider>();
    final attendanceId = int.tryParse(widget.attendanceId);
    
    if (attendanceId == null) return;
    
    final record = provider.getFilteredAttendanceById(attendanceId);
    if (record == null) return;

    String selectedStatus = record.status;
    String? keterangan = record.keterangan;
    final keteranganController = TextEditingController(text: keterangan ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Status Absensi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siswa: ${record.namaSiswa}', // Fixed: Removed ?? 'Tidak diketahui'
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Status Absensi',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['Hadir', 'Alpha', 'Sakit', 'Izin']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Keterangan (Opsional)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan keterangan...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await provider.updateAttendanceStatus(
                  attendanceId,
                  selectedStatus,
                  keteranganController.text.trim().isEmpty 
                      ? null 
                      : keteranganController.text.trim(),
                );
                
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status absensi berhasil diupdate'),
                        backgroundColor: Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal update status: ${provider.error}'),
                        backgroundColor: const Color(0xFFE53E3E),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}