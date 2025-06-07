import 'package:flutter/material.dart';
import '../../../shared/widgets/bottom_navbar.dart'; 
import 'package:go_router/go_router.dart';
// import '../../../../core/constants/strings.dart';

class StudentAttendanceSuccessPage extends StatelessWidget {
  final String subject;
  final String date;
  final String time;
  final String status;

  // Indeks dan role pengguna default
  static const int _selectedIndex = 1;
  static const String userRole = 'siswa';

  const StudentAttendanceSuccessPage({
    Key? key,
    required this.subject,
    required this.date,
    required this.time,
    required this.status,
  }) : super(key: key);
  
  // Constructor untuk menerima data dari GoRouter
  static StudentAttendanceSuccessPage fromExtra(BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    return StudentAttendanceSuccessPage(
      subject: extra['subject'] ?? 'Tidak diketahui',
      date: extra['date'] ?? '-',
      time: extra['time'] ?? '-',
      status: extra['status'] ?? 'Hadir',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Kembali langsung ke halaman absensi
            context.go('/student/attendance');
          },
        ),
        title: const Text("Strings.TittleSuccess", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
          ),
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo centang
              const Icon(Icons.check_circle, size: 100, color: Colors.white),
              const SizedBox(height: 16),
              // Teks absen berhasil
              const Text(
                "Strings.AttendanceSuccess",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Card keterangan
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.book,
                        label: "Strings.CourseSuccess",
                        value: subject,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: "Strings.DateSuccess",
                        value: date,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: "Strings.TimeScan",
                        value: time,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.lock,
                        label: "Strings.StatusScan",
                        value: status,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go('/student/attendance');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali ke Absensi'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        userRole: userRole,
        context: context,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  static const double _labelWidth =
      120; // lebar tetap untuk teks label tanpa ':'

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 12),
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Tanda ':' dipisah agar bisa sejajar
        const Text(
          ':',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
