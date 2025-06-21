import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/bottom_navbar.dart';

class StudentAttendanceSuccessPage extends StatelessWidget {
  final String subject;
  final String date;
  final String time;
  final String status;

  static const int _selectedIndex = 1;
  static const String userRole = 'siswa';

  const StudentAttendanceSuccessPage({
    Key? key,
    required this.subject,
    required this.date,
    required this.time,
    required this.status,
  }) : super(key: key);
  
  static StudentAttendanceSuccessPage fromExtra(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return StudentAttendanceSuccessPage(
      subject: extra['subject'] ?? 'Mata Pelajaran',
      date: extra['date'] ?? _formatDate(DateTime.now()),
      time: extra['time'] ?? _formatTime(DateTime.now()),
      status: extra['status'] ?? 'Hadir',
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return const Color(0xFF4CAF50);
      case 'alpha': return const Color(0xFFEF4444);
      case 'sakit': return const Color(0xFF8B5CF6);
      case 'izin': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF4CAF50);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir': return Icons.check_circle_outline;
      case 'alpha': return Icons.cancel_outlined;
      case 'sakit': return Icons.sick_outlined;
      case 'izin': return Icons.event_busy_outlined;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/student/attendance'),
        ),
        title: const Text(
          'Absensi Berhasil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ Success Animation Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF4CAF50).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ✅ Success Icon with Animation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ✅ Success Title
                  const Text(
                    'Absensi Berhasil!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ✅ Success Subtitle
                  Text(
                    'Data absensi Anda telah tersimpan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ✅ Attendance Details Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ✅ Card Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Detail Absensi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // ✅ Card Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.book_outlined,
                          'Mata Pelajaran',
                          subject,
                          const Color(0xFF2196F3),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Tanggal',
                          date,
                          const Color(0xFF10B981),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailRow(
                          Icons.access_time_outlined,
                          'Waktu Scan',
                          time,
                          const Color(0xFFF59E0B),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailRow(
                          _getStatusIcon(status),
                          'Status',
                          status,
                          statusColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ✅ Action Buttons
            Column(
              children: [
                // ✅ Primary Button - Kembali ke Absensi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/student/attendance'),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Kembali ke Absensi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // ✅ Secondary Button - Lihat History
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/student/attendance?tab=1'), // Go to history tab
                    icon: const Icon(Icons.history, size: 20),
                    label: const Text('Lihat Riwayat Absensi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF2196F3)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        userRole: userRole,
        context: context,
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}