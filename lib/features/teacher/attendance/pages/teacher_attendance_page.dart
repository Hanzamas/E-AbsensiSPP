import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../attendance/data/model/teaching_schedule_model.dart';
import '../provider/teacher_attendance_provider.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../dashboard/provider/teacher_dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
      // ✅ UPDATE: AppBar dengan icon dan title konsisten
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
                Icons.assignment_turned_in,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Absensi',
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
        
        automaticallyImplyLeading: false, // ✅ Hilangkan back button
        bottom: TabBar(
          // isScrollable: true,
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          tabs: const [
            Tab(text: 'Jadwal'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Pertemuan'),
            Tab(text: 'QRCode'),
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
              _MeetingHistoryTab(provider: provider),
              _QRCodeTab(provider: provider),
            ],
          );
        },
      ),
      // ✅ FIX: Dynamic role dari provider
      bottomNavigationBar: Builder(
        builder: (context) {
          // Ambil userRole langsung dari TeacherDashboardProvider
          final dashboardProvider = Provider.of<TeacherDashboardProvider>(context, listen: false);
          final userRole = dashboardProvider.userProfile?.role?.toLowerCase() ?? 'guru';

          return CustomBottomNavBar(
            currentIndex: 1,
            userRole: userRole,
            context: context,
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

class _MeetingHistoryTab extends StatefulWidget {
  final TeacherAttendanceProvider provider;

  const _MeetingHistoryTab({required this.provider});

  @override
  State<_MeetingHistoryTab> createState() => _MeetingHistoryTabState();
}

class _MeetingHistoryTabState extends State<_MeetingHistoryTab> {
  String? selectedClass;
  DateTime? selectedDate;
  String? selectedSubject; 

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.provider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 16),
            _buildMeetingList(),
            const SizedBox(height: 100), // Space for bottom navbar
          ],
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Pertemuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter kelas dan mata pelajaran (baris pertama)
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: 'Kelas',
                  value: selectedClass ?? 'Semua Kelas',
                  icon: Icons.class_,
                  onTap: _showClassFilter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'Mata Pelajaran',
                  value: selectedSubject ?? 'Semua Mapel',
                  icon: Icons.book_outlined,
                  onTap: _showSubjectFilter,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Filter tanggal (baris kedua)
          _buildFilterButton(
            label: 'Tanggal',
            value: selectedDate != null ? _formatDate(selectedDate!) : 'Semua Tanggal',
            icon: Icons.calendar_today,
            onTap: () => _showDatePicker(context),
          ),
          
          if (selectedClass != null || selectedDate != null || selectedSubject != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedClass = null;
                        selectedDate = null;
                        selectedSubject = null; // Reset filter mata pelajaran
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Hapus Filter'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
   // Implementasi metode untuk menampilkan filter mata pelajaran
  void _showSubjectFilter() {
    // Dapatkan daftar mata pelajaran unik dari provider
    final subjects = widget.provider.availableSubjects;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pilih Mata Pelajaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Semua Mata Pelajaran'),
                  selected: selectedSubject == null,
                  onTap: () {
                    setState(() {
                      selectedSubject = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...subjects.map((subject) => ListTile(
                  title: Text(subject),
                  selected: selectedSubject == subject,
                  onTap: () {
                    setState(() {
                      selectedSubject = subject;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingList() {
    // Group data by date and class
    final meetings = _groupAttendanceByClassAndDate();

    if (meetings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return _buildMeetingCard(meeting);
      },
    );
  }
  
 // Perbarui logika filter di metode _groupAttendanceByClassAndDate
  List<Map<String, dynamic>> _groupAttendanceByClassAndDate() {
    final attendanceHistory = widget.provider.attendanceHistory;
    final grouped = <String, Map<String, dynamic>>{};
    
    // Group by class and date
    for (final record in attendanceHistory) {
      final key = '${record.namaKelas}_${record.tanggal.toIso8601String().split('T')[0]}';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'class': record.namaKelas,
          'date': record.tanggal,
          'subject': record.namaMapel,
          'time': '${record.jamMulai} - ${record.jamSelesai}',
          'total': 0,
          'present': 0,
          'absent': 0,
          'sick': 0,
          'permission': 0,
          'students': <Map<String, dynamic>>[],
        };
      }
      
      // Add student to the meeting
      grouped[key]!['students']!.add({
        'name': record.namaSiswa,
        'nis': record.nis,
        'status': record.status,
        'scanTime': record.waktuScan,
        'note': record.keterangan,
      });
      
      // Update counters
      grouped[key]!['total'] = grouped[key]!['total']! + 1;
      
      switch (record.status.toLowerCase()) {
        case 'hadir':
          grouped[key]!['present'] = grouped[key]!['present']! + 1;
          break;
        case 'alpha':
          grouped[key]!['absent'] = grouped[key]!['absent']! + 1;
          break;
        case 'sakit':
          grouped[key]!['sick'] = grouped[key]!['sick']! + 1;
          break;
        case 'izin':
          grouped[key]!['permission'] = grouped[key]!['permission']! + 1;
          break;
      }
    }
    
    // Apply filters
    final filtered = grouped.values.where((meeting) {
      bool matchClass = true;
      bool matchDate = true;
      bool matchSubject = true;
      
      if (selectedClass != null) {
        matchClass = meeting['class'] == selectedClass;
      }
      
      if (selectedDate != null) {
        final meetingDate = meeting['date'] as DateTime;
        matchDate = meetingDate.year == selectedDate!.year &&
                    meetingDate.month == selectedDate!.month &&
                    meetingDate.day == selectedDate!.day;
      }
      
      // Tambahkan kondisi filter mata pelajaran
      if (selectedSubject != null) {
        matchSubject = meeting['subject'] == selectedSubject;
      }
      
      return matchClass && matchDate && matchSubject;
    }).toList();
    
    // Sort by date (newest first)
    filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    return filtered;
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    final date = meeting['date'] as DateTime;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final attendanceRate = meeting['total'] > 0 
        ? (meeting['present'] / meeting['total'] * 100).toStringAsFixed(0)
        : '0';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Padding(
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
                        Icons.menu_book,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting['subject'] ?? 'Mata Pelajaran',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meeting['class'] ?? 'Kelas',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        Text(
                          meeting['time'] ?? '00:00 - 00:00',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Attendance stats
                Row(
                  children: [
                    _AttendanceStatChip(
                      label: 'Hadir',
                      value: '${meeting['present']}',
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    _AttendanceStatChip(
                      label: 'Alpha',
                      value: '${meeting['absent']}',
                      color: const Color(0xFFE53E3E),
                    ),
                    const SizedBox(width: 8),
                    _AttendanceStatChip(
                      label: 'Sakit',
                      value: '${meeting['sick']}',
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 8),
                    _AttendanceStatChip(
                      label: 'Izin',
                      value: '${meeting['permission']}',
                      color: const Color(0xFF2196F3),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Progress bar
                Row(
                  children: [
                    Text(
                      'Kehadiran: $attendanceRate%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: meeting['total'] > 0 
                              ? meeting['present'] / meeting['total'] 
                              : 0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            double.parse(attendanceRate) > 75 
                                ? const Color(0xFF4CAF50)
                                : double.parse(attendanceRate) > 50
                                    ? const Color(0xFFFFA000)
                                    : const Color(0xFFF44336),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Implement detail page navigation
                    _showMeetingDetail(meeting);
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Detail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.only(top: 16),
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
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Data Pertemuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada data pertemuan yang sesuai dengan filter yang diterapkan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterButton({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showClassFilter() {
    // Get unique class names
    final classes = widget.provider.availableClasses;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pilih Kelas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Semua Kelas'),
                  selected: selectedClass == null,
                  onTap: () {
                    setState(() {
                      selectedClass = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...classes.map((className) => ListTile(
                  title: Text(className),
                  selected: selectedClass == className,
                  onTap: () {
                    setState(() {
                      selectedClass = className;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  void _showMeetingDetail(Map<String, dynamic> meeting) {
    // Implement showing meeting details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final students = meeting['students'] as List<Map<String, dynamic>>;
          
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with class info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting['subject'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${meeting['class']} - ${_formatDate(meeting['date'])}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const Divider(height: 24),
                
                // Summary
                Text(
                  'Ringkasan Kehadiran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Stats row
                Row(
                  children: [
                    _DetailStatCard(
                      title: 'Total',
                      value: '${meeting['total']}',
                      color: Colors.grey[700]!,
                    ),
                    const SizedBox(width: 8),
                    _DetailStatCard(
                      title: 'Hadir',
                      value: '${meeting['present']}',
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    _DetailStatCard(
                      title: 'Alpha',
                      value: '${meeting['absent']}',
                      color: const Color(0xFFE53E3E),
                    ),
                    const SizedBox(width: 8),
                    _DetailStatCard(
                      title: 'Sakit/Izin',
                      value: '${meeting['sick'] + meeting['permission']}',
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Student list header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Siswa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${students.length} siswa',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Student list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentItem(student);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStudentItem(Map<String, dynamic> student) {
    final Color statusColor = _getStatusColor(student['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'NIS: ${student['nis']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  student['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (student['scanTime'] != null)
                Text(
                  'Scan: ${_formatScanTime(student['scanTime'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF4CAF50);
      case 'alpha':
        return const Color(0xFFE53E3E);
      case 'sakit':
        return const Color(0xFFFF9800);
      case 'izin':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }
  
  String _formatScanTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }
}

class _AttendanceStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AttendanceStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _DetailStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
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
            // 1. Jadwal Hari Ini - SEKARANG DI DALAM CARD
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: const Text(
                      'Jadwal Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  
                  if (provider.todaySchedule.isNotEmpty)
                    ...provider.todaySchedule.map((schedule) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _ScheduleCard(
                          schedule: schedule,
                          onStartSession: () => _startSession(context, schedule.id),
                          isStartingSession: provider.isCreatingSession,
                          showBorder: false,
                        ),
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _EmptyStateCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Tidak Ada Kelas Hari Ini',
                        subtitle: 'Anda tidak memiliki jadwal mengajar hari ini',
                      ),
                    ),
                ],
              ),
            ),
                    
            const SizedBox(height: 24),
            
            // 2. Jadwal Lengkap - SEKARANG HEADER DI DALAM CARD
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: const Text(
                      'Jadwal Lengkap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),

                  _buildWeeklyScheduleTabs(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 3. Statistik kehadiran
            _buildStatsCard(),
            
            // 4. Grafik Tren
            const SizedBox(height: 24),
            _buildAttendanceTrendsCard(),
            
            // Space for bottom navbar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  // Pindahkan implementasi tab jadwal ke method terpisah
Widget _buildWeeklyScheduleTabs() {
  final daysOfWeek = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  
  return DefaultTabController(
    length: daysOfWeek.length,
    child: Column(
      children: [
        // Tab Bar untuk hari-hari
        TabBar(
          isScrollable: true,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          padding: EdgeInsets.zero, // Hapus padding default
          tabAlignment: TabAlignment.start, // Ratakan ke kiri
          indicatorSize: TabBarIndicatorSize.tab, // Ukuran indikator sesuai tab
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: const Color(0xFF2196F3), width: 3),
            ),
          ),
          tabs: daysOfWeek.map((day) => Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(day),
            ),
          )).toList(),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        
        // Content area
        SizedBox(
          height: 300,
          child: TabBarView(
            children: daysOfWeek.map((day) {
              // Filter jadwal berdasarkan hari menggunakan provider
              final schedules = provider.getSchedulesByDay(day.toLowerCase());
              
              if (schedules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada jadwal di hari $day',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final isToday = provider.isScheduleToday(schedule);
                  
                  return _WeeklyScheduleCard(
                    schedule: schedule,
                    isToday: isToday,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

    // Perbarui metode untuk tampilan jadwal mingguan yang lebih rapi
  Widget _buildWeeklySchedule() {
    final daysOfWeek = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Lengkap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              DefaultTabController(
                length: daysOfWeek.length,
                child: Column(
                  children: [
                    // Tab Bar untuk hari-hari
                    TabBar(
                      isScrollable: true,
                      labelColor: const Color(0xFF2196F3),
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      padding: EdgeInsets.zero, // Hapus padding default
                      tabAlignment: TabAlignment.start, // Ratakan ke kiri
                      indicatorSize: TabBarIndicatorSize.tab, // Ukuran indikator sesuai tab
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: const Color(0xFF2196F3), width: 3),
                        ),
                      ),
                      tabs: daysOfWeek.map((day) => Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(day),
                        ),
                      )).toList(),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    
                    // Content area
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        children: daysOfWeek.map((day) {
                          // Filter jadwal berdasarkan hari menggunakan provider
                          final schedules = provider.getSchedulesByDay(day.toLowerCase());
                          
                          if (schedules.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada jadwal di hari $day',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: schedules.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final schedule = schedules[index];
                              final isToday = provider.isScheduleToday(schedule);
                              
                              return _WeeklyScheduleCard(
                                schedule: schedule,
                                isToday: isToday,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildStatsCard() {
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
        const Text(
          'Statistik Kehadiran Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 20),
        
        // Progress bar kehadiran
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tingkat Kehadiran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              provider.attendanceRateText,
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
            value: provider.attendanceRate / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              provider.attendanceRate > 75 ? 
                const Color(0xFF4CAF50) : 
                provider.attendanceRate > 50 ?
                  const Color(0xFFFFA000) :
                  const Color(0xFFF44336),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 24),
        
        // Donut chart untuk distribusi status
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: provider.presentToday.toDouble(),
                              color: const Color(0xFF4CAF50),
                              radius: 50,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: provider.absentToday.toDouble(),
                              color: const Color(0xFFF44336),
                              radius: 50,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: provider.sickToday.toDouble(),
                              color: const Color(0xFFFF9800),
                              radius: 50,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: provider.permissionToday.toDouble(),
                              color: const Color(0xFF9C27B0),
                              radius: 50,
                              title: '',
                            ),
                          ],
                          centerSpaceRadius: 30,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    Text(
                      '${provider.totalStudents}\nSiswa',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Hadir', provider.presentToday, const Color(0xFF4CAF50)),
                      const SizedBox(height: 8),
                      _buildLegendItem('Alpha', provider.absentToday, const Color(0xFFF44336)),
                      const SizedBox(height: 8),
                      _buildLegendItem('Sakit', provider.sickToday, const Color(0xFFFF9800)),
                      const SizedBox(height: 8),
                      _buildLegendItem('Izin', provider.permissionToday, const Color(0xFF9C27B0)),
                    ],
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

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    // Di dalam _ScheduleTab
  Widget _buildAttendanceTrendsCard() {
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
          const Text(
            'Tren Kehadiran (7 Hari Terakhir)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: FutureBuilder<Map<String, List<double>>>(
              future: provider.getAttendanceTrend(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data tren kehadiran'),
                  );
                }
                
                final data = snapshot.data!;
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(days[value.toInt()]);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}%');
                          },
                          reservedSize: 35,
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          data['attendance']!.length, 
                          (index) => FlSpot(index.toDouble(), data['attendance']![index]),
                        ),
                        isCurved: true,
                        color: const Color(0xFF4CAF50),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: 100,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// Ubah _HistoryTab menjadi StatefulWidget
class _HistoryTab extends StatefulWidget {
  final TeacherAttendanceProvider provider;
  
  const _HistoryTab({required this.provider});
  
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  // State untuk multiple selection
  final Set<int> _selectedIds = <int>{};
  bool _isProcessing = false;
  
  TeacherAttendanceProvider get provider => widget.provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Enhanced Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      label: 'Kelas',
                      value: provider.selectedClass ?? 'Semua Kelas',
                      icon: Icons.class_outlined,
                      isSelected: provider.selectedClass != null,
                      onTap: () => _showClassFilter(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterButton(
                      label: 'Mata Pelajaran',
                      value: provider.selectedSubject ?? 'Semua Mapel',
                      icon: Icons.book_outlined,
                      isSelected: provider.selectedSubject != null,
                      onTap: () => _showSubjectFilter(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      label: 'Tanggal',
                      value: provider.selectedDate != null 
                          ? _formatDate(provider.selectedDate!) 
                          : 'Semua Tanggal',
                      icon: Icons.calendar_today,
                      isSelected: provider.selectedDate != null,
                      onTap: () => _showDatePicker(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterButton(
                      label: 'Status',
                      value: provider.selectedStatus ?? 'Semua Status',
                      icon: Icons.check_circle_outline,
                      isSelected: provider.selectedStatus != null,
                      onTap: () => _showStatusFilter(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter chips showing active filters
                  if (provider.hasFiltersApplied)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (provider.selectedClass != null)
                              _buildFilterChip(
                                label: 'Kelas: ${provider.selectedClass}',
                                onRemove: () => provider.setClassFilter(null),
                              ),
                            if (provider.selectedSubject != null)
                              _buildFilterChip(
                                label: 'Mapel: ${provider.selectedSubject}',
                                onRemove: () => provider.setSubjectFilter(null),
                              ),
                            if (provider.selectedDate != null)
                              _buildFilterChip(
                                label: 'Tanggal: ${_formatDate(provider.selectedDate!)}',
                                onRemove: () => provider.setDateFilter(null),
                              ),
                            if (provider.selectedStatus != null)
                              _buildFilterChip(
                                label: 'Status: ${provider.selectedStatus}',
                                onRemove: () => provider.setStatusFilter(null),
                              ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Clear filters button
                  if (provider.hasFiltersApplied)
                    TextButton.icon(
                      onPressed: () => provider.clearFilters(),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Hapus Filter'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Filter result count
        if (provider.hasFiltersApplied)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Text(
                  'Ditemukan: ${provider.totalFilteredRecords} data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Tambahkan bulk action bar saat ada item yang dipilih
        if (_selectedIds.isNotEmpty)
          _buildBulkActionBar(),
        
        // Attendance List with checkboxes
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.refreshData();
              setState(() => _selectedIds.clear());
            },
            child: provider.filteredAttendance.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: provider.filteredAttendance.length,
                    itemBuilder: (context, index) {
                      final record = provider.filteredAttendance[index];
                      final isSelected = _selectedIds.contains(record.idAbsensi);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _AttendanceCardWithCheckbox(
                          record: record,
                          isSelected: isSelected,
                          onTap: () => context.push('/teacher/attendance/detail/${record.idAbsensi}'),
                          onCheckboxChanged: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedIds.add(record.idAbsensi);
                              } else {
                                _selectedIds.remove(record.idAbsensi);
                              }
                            });
                          },
                        ),
                      );
                    },
                  )
                : const _EmptyStateCard(
                    icon: Icons.filter_alt_off,
                    title: 'Tidak Ada Data',
                    subtitle: 'Tidak ada data absensi dengan filter yang diterapkan',
                  ),
          ),
        ),
      ],
    );
  }

  // UI untuk filter button yang konsisten
  Widget _buildFilterButton({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 12,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  // Bulk Action Bar
  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFE3F2FD),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_selectedIds.length} siswa dipilih',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2196F3),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _selectedIds.length == provider.filteredAttendance.length
                  ? () => setState(() => _selectedIds.clear())
                  : () => setState(() => _selectedIds.addAll(
                      provider.filteredAttendance.map((e) => e.idAbsensi)
                    )),
                child: Text(
                  _selectedIds.length == provider.filteredAttendance.length
                    ? 'Batalkan Semua'
                    : 'Pilih Semua',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
          
          // Action buttons
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBulkActionButton('Hadir', Icons.check_circle, const Color(0xFF4CAF50)),
                  _buildBulkActionButton('Alpha', Icons.cancel, const Color(0xFFE53E3E)),
                  _buildBulkActionButton('Sakit', Icons.healing, const Color(0xFFFF9800)),
                  _buildBulkActionButton('Izin', Icons.event_busy, const Color(0xFF9C27B0)),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildBulkActionButton(String status, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _showBulkConfirmation(status),
      icon: Icon(icon, size: 16),
      label: Text(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  void _showBulkConfirmation(String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah ke $status'),
        content: Text(
          'Anda akan mengubah status ${_selectedIds.length} siswa menjadi $status. Lanjutkan?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateBulkStatus(status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateBulkStatus(String status) async {
    if (_selectedIds.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    int success = 0;
    int failed = 0;
    
    // Menggunakan API satu per satu
    for (final id in _selectedIds) {
      try {
        final result = await provider.updateAttendanceStatus(id, status, null);
        if (result) {
          success++;
        } else {
          failed++;
        }
      } catch (e) {
        failed++;
      }
      
      // Update UI setelah setiap pemrosesan untuk feedback visual
      if (mounted) {
        setState(() {});  // Refresh UI untuk menunjukkan progres
      }
    }
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _selectedIds.clear(); // Clear selection after processing
      });
      
      // Refresh data untuk mendapatkan status terbaru
      await provider.refreshData();
      
      // Tampilkan hasil operasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah: $success, gagal: $failed'),
          backgroundColor: failed > 0 ? Colors.orange : Colors.green,
          behavior: SnackBarBehavior.floating,
          action: failed > 0 ? SnackBarAction(
            label: 'Detail',
            onPressed: () {
              // Logika untuk menampilkan detail kegagalan jika diperlukan
            },
          ) : null,
        ),
      );
    }
  }

  // Filter dialog methods
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

  void _showStatusFilter(BuildContext context) {
    final statuses = ['Hadir', 'Alpha', 'Sakit', 'Izin'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pilih Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Semua Status'),
                  selected: provider.selectedStatus == null,
                  onTap: () {
                    provider.setStatusFilter(null);
                    Navigator.pop(context);
                  },
                ),
                ...statuses.map((status) => ListTile(
                  title: Text(status),
                  selected: provider.selectedStatus == status,
                  onTap: () {
                    provider.setStatusFilter(status);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClassFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pilih Kelas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Semua Kelas'),
                  selected: provider.selectedClass == null,
                  onTap: () {
                    provider.setClassFilter(null);
                    Navigator.pop(context);
                  },
                ),
                ...provider.availableClasses.map((className) => ListTile(
                  title: Text(className),
                  selected: provider.selectedClass == className,
                  onTap: () {
                    provider.setClassFilter(className);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Pilih Mata Pelajaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Semua Mata Pelajaran'),
                  selected: provider.selectedSubject == null,
                  onTap: () {
                    provider.setSubjectFilter(null);
                    Navigator.pop(context);
                  },
                ),
                ...provider.availableSubjects.map((subject) => ListTile(
                  title: Text(subject),
                  selected: provider.selectedSubject == subject,
                  onTap: () {
                    provider.setSubjectFilter(subject);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Tambahkan class _AttendanceCardWithCheckbox untuk dukungan bulk action
class _AttendanceCardWithCheckbox extends StatelessWidget {
  final dynamic record;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheckboxChanged;

  const _AttendanceCardWithCheckbox({
    required this.record,
    required this.isSelected,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onCheckboxChanged(value ?? false),
              activeColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Card content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
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
          ),
        ],
      ),
    );
  }
}

// QR Code Tab dengan fitur lengkap
class _QRCodeTab extends StatefulWidget {
  final TeacherAttendanceProvider provider;

  const _QRCodeTab({required this.provider});

  @override
  State<_QRCodeTab> createState() => _QRCodeTabState();
}

class _QRCodeTabState extends State<_QRCodeTab> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    if (!widget.provider.hasActiveSession) return;
    
    try {
      final session = widget.provider.activeSession!;
      
      // Parse jam selesai
      final parts = session.jamSelesai.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Buat DateTime untuk waktu berakhir hari ini
      final now = DateTime.now();
      final endTime = DateTime(
        now.year, 
        now.month, 
        now.day,
        hour,
        minute,
      );
      
      // Hitung durasi tersisa
      _remainingTime = endTime.difference(now);
      
      // Mulai timer jika masih ada waktu tersisa
      if (_remainingTime.inSeconds > 0) {
        _startTimer();
      }
    } catch (e) {
      print('Error initializing timer: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          // Refresh data untuk memeriksa apakah sesi sudah berakhir
          widget.provider.refreshData();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.provider.refreshData();
        _initTimer(); // Reinitialize timer after refresh
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.provider.hasActiveSession)
              _buildActiveSessionCard()
            else
              _buildNoActiveSessionCard(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard() {
    final session = widget.provider.activeSession!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_remainingTime),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // QR Code
          Screenshot(
            controller: _screenshotController,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: session.qrToken,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    gapless: true,
                    embeddedImage: const AssetImage('assets/logo_small.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QR Token: ${session.qrToken}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Session Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  'Tanggal',
                  session.formattedDate,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 10),
                _infoRow(
                  'Waktu',
                  session.formattedTime,
                  Icons.access_time,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Share buttons
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  'WhatsApp',
                  Icons.call,
                  const Color(0xFF25D366),
                  () => _shareQrCode('whatsapp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shareButton(
                  'Email',
                  Icons.email,
                  const Color(0xFF4285F4),
                  () => _shareQrCode('email'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _shareButton(
            'Bagikan QR Code',
            Icons.share,
            const Color(0xFF757575),
            () => _shareQrCode('other'),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _shareButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isFullWidth = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFullWidth ? Colors.grey.shade800 : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _shareQrCode(String method) async {
    try {
      // Capture QR Code as image
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) return;
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(imageBytes);
      
      final session = widget.provider.activeSession!;
      final text = 'QR Code untuk absensi kelas. Token: ${session.qrToken}';
      
      switch (method) {
        case 'whatsapp':
          // On iOS and Android, this will open WhatsApp sharing
          await Share.shareXFiles(
            [XFile(file.path)], 
            text: text,
            subject: 'QR Code Absensi',
          );
          break;
        case 'email':
          // This will typically open email apps
          await Share.shareXFiles(
            [XFile(file.path)],
            text: text,
            subject: 'QR Code Absensi Kelas',
          );
          break;
        default:
          // Default share dialog
          await Share.shareXFiles(
            [XFile(file.path)],
            text: text,
            subject: 'QR Code Absensi',
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNoActiveSessionCard() {
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
            Icons.qr_code_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak Ada Sesi Aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
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

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) {
      return 'Sesi Berakhir';
    }
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
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


// Reusable Components (unchanged)
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



// Weekly Schedule Card dengan desain yang konsisten
class _WeeklyScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final bool isToday;

  const _WeeklyScheduleCard({
    required this.schedule,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container dengan style konsisten
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Informasi jadwal di tengah
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  schedule.namaKelas ?? 'Kelas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          
          // Waktu dan tahun ajaran di kanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Waktu dengan warna hijau jika jadwal hari ini
              Text(
                schedule.formattedTime ?? '00:00 - 00:00',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isToday
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule.tahunAjaran ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback? onStartSession;
  final bool isStartingSession;
  final bool showBorder; // Parameter baru

  const _ScheduleCard({
    required this.schedule,
    this.onStartSession,
    required this.isStartingSession,
    this.showBorder = true, // Default true untuk backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Terapkan shadow dan border hanya jika showBorder true
        boxShadow: showBorder ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
        border: showBorder ? Border.all(color: Colors.grey.shade200) : null,
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