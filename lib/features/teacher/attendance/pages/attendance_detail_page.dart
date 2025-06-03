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
  String? selectedStatus;
  final keteranganController = TextEditingController();
  bool isEditMode = false;

  @override
  void dispose() {
    keteranganController.dispose();
    super.dispose();
  }

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
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
            icon: Icon(isEditMode ? Icons.close : Icons.edit),
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

          // Initialize status and keterangan when record changes
          if (selectedStatus == null) {
            selectedStatus = record.status;
            keteranganController.text = record.keterangan ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentInfoCard(record),
                const SizedBox(height: 16),
                _buildAttendanceInfoCard(record),
                const SizedBox(height: 16),
                
                // Form update status langsung di halaman (tanpa popup)
                if (isEditMode) _buildUpdateStatusForm(provider, record, attendanceId),
                
                // Tampilkan tombol update hanya jika tidak dalam mode edit
                if (!isEditMode)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditMode = true;
                          selectedStatus = record.status;
                          keteranganController.text = record.keterangan ?? '';
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Status Absensi'),
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

    // Form update status langsung di halaman (pengganti popup dialog)
  Widget _buildUpdateStatusForm(TeacherAttendanceProvider provider, dynamic record, int attendanceId) {
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
            'Update Status Absensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          
          // Status field
          const Text(
            'Status Absensi',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              items: ['Hadir', 'Alpha', 'Sakit', 'Izin']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Keterangan field
          const Text(
            'Keterangan (Opsional)',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: keteranganController,
              decoration: const InputDecoration(
                hintText: 'Masukkan keterangan...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isEditMode = false;
                    // Reset values
                    selectedStatus = record.status;
                    keteranganController.text = record.keterangan ?? '';
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: provider.isUpdatingAttendance
                    ? null
                    : () async {
                        final success = await provider.updateAttendanceStatus(
                          attendanceId,
                          selectedStatus!,
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
                            setState(() {
                              isEditMode = false;
                            });
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  disabledBackgroundColor: const Color(0xFF2196F3).withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: provider.isUpdatingAttendance
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 14),
                      ),
              ),
            ],
          ),
        ],
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
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Update Status Absensi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Siswa info
                Text(
                  'Siswa: ${record.namaSiswa}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Status field
                const Text(
                  'Status Absensi',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                    items: ['Hadir', 'Alpha', 'Sakit', 'Izin']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // Keterangan field
                const Text(
                  'Keterangan (Opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: keteranganController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan keterangan...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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