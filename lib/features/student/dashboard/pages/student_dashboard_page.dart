import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// ✅ Remove SharedPreferences import
import '../../../../core/constants/assets.dart';
import '../../../shared/animations/fade_in_animation.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../shared/widgets/loading.dart';
import '../provider/student_dashboard_provider.dart'; // ✅ Update provider
import '../data/models/schedule_model.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  bool _isLoading = true;
  String? _selectedSubject;
  bool _didInitLoad = false;
  static const List<String> hariList = [
    'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'
  ];
  static const List<String> orderedHariList = [
    'minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu'
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Remove welcome popup - direct load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_didInitLoad) {
      // ✅ Update provider reference
      final studentProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
      studentProvider.loadDashboardData();
    }
  }
  
  Future<void> _loadInitialData() async {
    // ✅ Update provider reference
    final studentProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
    
    try {
      await studentProvider.loadDashboardData();
      _didInitLoad = true;
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // ✅ Update provider reference
    final studentProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
    setState(() { _isLoading = true; });
    try {
      await studentProvider.refreshData();
    } catch (e) {
      // ignore error, tetap pakai cache
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: _buildBody(),
      ),
      // ✅ Update bottom nav to get role from provider
      bottomNavigationBar: Consumer<StudentDashboardProvider>(
        builder: (context, provider, _) {
          // Get role from user profile, fallback to 'siswa'
          final userRole = provider.userProfile?.role?.toLowerCase() ?? 'siswa';
          
          return CustomBottomNavBar(
            currentIndex: 0,
            userRole: userRole, // ✅ Dynamic role from /users/my
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          stops: [0.0, 0.8],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              // 1. Jadwal Pelajaran di atas
              _buildScheduleSection(),
              const SizedBox(height: 24),
              // 2. Statistik Kehadiran di tengah
              _buildAttendanceStatsSection(),
              const SizedBox(height: 24),
              // 3. Menu Aksi Cepat di bawah
              _buildMenuCards(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // ✅ Update provider reference
    return Consumer<StudentDashboardProvider>(
      builder: (context, studentProvider, _) {
        final userProfile = studentProvider.userProfile;
        final nama = userProfile?.namaLengkap ?? userProfile?.username ?? 'Siswa';
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
              const SizedBox(height: 24),
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
                      text: nama,
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
                'Lihat aktivitasmu dan semoga hari harimu menyenangkan',
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
    );
  }

Widget _buildMenuCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Assets.absensi,
                      label: 'Absensi',
                      onTap: () {
                        context.go('/student/attendance');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Assets.spp,
                      label: 'Pembayaran SPP',
                      onTap: () {
                        context.go('/student/spp');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

Widget _buildScheduleSection() {
  return Consumer<StudentDashboardProvider>(
    builder: (context, provider, _) {
      final isLoading = provider.isLoading;
      
      // PERBAIKAN: Ambil semua jadwal, bukan hanya jadwal hari ini
      final allSchedules = provider.allSchedules;
      
      // Filter berdasarkan dropdown yang dipilih
      List<Schedule> schedules;
      if (_selectedDay == 'semua') {
        schedules = allSchedules; // Tampilkan semua jadwal
      } else {
        // Filter jadwal berdasarkan hari yang dipilih
        schedules = allSchedules.where(
          (schedule) => schedule.hari.toLowerCase() == _selectedDay.toLowerCase()
        ).toList();
      }
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
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
                padding: const EdgeInsets.all(16),
                child: Row(
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
                            Icons.calendar_today,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jadwal Pelajaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    _buildFilterDropdown(),
                  ],
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: FadeInAnimation(child: DefaultLoading()),
                )
              else if (schedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada jadwal pada hari yang dipilih.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildScheduleTable(schedules),
            ],
          ),
        ),
      );
    },
  );
}



  String _selectedDay = 'semua';

  Widget _buildFilterDropdown() {
    final now = DateTime.now();
    final currentDayName = orderedHariList[now.weekday % 7];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDay,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF2196F3),
          ),
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          items: [
            const DropdownMenuItem(
              value: 'semua',
              child: Text('All'),
            ),
            ...hariList.map((day) => DropdownMenuItem(
              value: day,
              child: Text(day.substring(0, 1).toUpperCase() + day.substring(1)),
            )),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDay = value;
              });
            }
          },
          style: const TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

Widget _buildAttendanceStatsSection() {
  return Consumer<StudentDashboardProvider>(
    builder: (context, provider, _) {
      final stats = provider.attendanceStats;
      final isLoading = provider.isLoading;
      
      // Dapatkan daftar mata pelajaran dari provider
      final subjects = provider.getAvailableSubjects();
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
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
                padding: const EdgeInsets.all(16),
                child: Row(
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
                          'Kehadiran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    // Filter Dropdown Mata Pelajaran
                    _buildSubjectFilterDropdown(subjects),
                  ],
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (stats.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada data absensi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Data akan muncul setelah Anda melakukan absensi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

// Widget dropdown filter mata pelajaran
Widget _buildSubjectFilterDropdown(List<String> subjects) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF2196F3).withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: const Color(0xFF2196F3).withOpacity(0.2),
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: _selectedSubject,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF2196F3),
        ),
        hint: const Text(
          'Semua Mapel',
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        isDense: true,
        borderRadius: BorderRadius.circular(8),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Semua Mapel'),
          ),
          ...subjects.map((subject) => DropdownMenuItem<String?>(
            value: subject,
            child: Text(subject),
          )),
        ],
        onChanged: (value) {
          setState(() {
            _selectedSubject = value;
          });
          // Reload stats dengan filter mata pelajaran
          Provider.of<StudentDashboardProvider>(context, listen: false)
              .loadAttendanceStatsBySubject(_selectedSubject);
        },
        style: const TextStyle(
          color: Color(0xFF2196F3),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

  // ✅ Keep ALL original table methods unchanged
  Widget _buildScheduleTable(List<Schedule> schedules) {
    // Get current day and time
    final now = DateTime.now();
    // Use orderedHariList for getting current day name
    final currentDayName = orderedHariList[now.weekday % 7];

    // Get tomorrow (besok) dan lusa (2 hari ke depan)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDayName = orderedHariList[tomorrow.weekday % 7];

    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));
    final dayAfterTomorrowDayName = orderedHariList[dayAfterTomorrow.weekday % 7];

    final currentTimeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Group schedules by day (we'll show all days together in a single table)
    final Map<String, List<Schedule>> schedulesMap = {};
    for (final schedule in schedules) {
      final day = schedule.hari.toLowerCase(); // schedule.hari should match names in orderedHariList
      if (!schedulesMap.containsKey(day)) {
        schedulesMap[day] = [];
      }
      schedulesMap[day]!.add(schedule);
    }

    // Create a flat list of all schedules to show in the table, sorted by day
    final List<Map<String, dynamic>> tableData = [];
    int counter = 1;
    
    // Filter days based on selection
    List<String> daysToShow = [];
    if (_selectedDay == 'semua') {
      // Show all days in the correct order
      daysToShow = orderedHariList; // Use orderedHariList for iteration order
    } else {
      // Show only the selected day
      daysToShow = [_selectedDay];
    }
    
    // Sort schedules by day of week in correct order
    for (final hari in daysToShow) {
      if (schedulesMap.containsKey(hari)) {
        // Sort schedules within this day by start time
        final daySchedules = schedulesMap[hari]!;
        daySchedules.sort((a, b) {
          // Parse time like "07:00" to compare
          final timeA = a.jamMulai;
          final timeB = b.jamMulai;
          return timeA.compareTo(timeB);
        });
        
        String lastDay = "";
        for (final schedule in daySchedules) {
          final currentDay = hari;
          final isNewDay = lastDay != currentDay;
          lastDay = currentDay;
          
          // Check if this is a current/today/tomorrow class
          bool isCurrentClass = false;
          // Compare schedule day name with current day name
          bool isTodayClass = currentDay == currentDayName;
          // Compare schedule day name with tomorrow day name
          bool isTomorrowClass = currentDay == tomorrowDayName;
          // Compare schedule day name with day after tomorrow name
          bool isDayAfterTomorrowClass = currentDay == dayAfterTomorrowDayName;
          
          if (isTodayClass) {
            // Check if current time is between start and end time
            if (currentTimeStr.compareTo(schedule.jamMulai) >= 0 && 
                currentTimeStr.compareTo(schedule.jamSelesai) <= 0) {
              isCurrentClass = true;
            }
          }
          
          tableData.add({
            'no': counter++,
            'hari': hari,
            'jam': schedule.formattedWaktu,
            'kelas': schedule.ruangKelas,
            'mapel': schedule.mapel,
            'guru': schedule.guruPengajar,
            'isNewDay': isNewDay,
            'isTodayClass': isTodayClass,
            'isCurrentClass': isCurrentClass,
            'isTomorrowClass': isTomorrowClass,
            'isDayAfterTomorrowClass': isDayAfterTomorrowClass,
          });
        }
      }
    }

    if (tableData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                color: Colors.grey,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Tidak ada jadwal pada hari yang dipilih.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${tableData.length} jadwal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                // Indikator status jadwal
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusIndicator('Berlangsung', Colors.green),
                      const SizedBox(width: 8),
                      _buildStatusIndicator('Hari Ini', Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatusIndicator('Besok', Colors.blueGrey),
                      const SizedBox(width: 8),
                      _buildStatusIndicator('Lusa', Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: _buildResponsiveTable(tableData, tomorrowDayName, dayAfterTomorrowDayName),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<Map<String, dynamic>> tableData, String tomorrowDay, String dayAfterTomorrowDay) {
    // Buat tabel dengan lebar yang responsif
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tabel akan menggunakan lebar container parent jika layar cukup lebar
        final double tableWidth = constraints.maxWidth;
        final bool isMobile = tableWidth < 500; // Deteksi jika layar kecil (mobile)
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            // Gunakan minimum width jika terlalu kecil, atau gunakan lebar container parent jika cukup besar
            width: isMobile ? 500 : tableWidth,
            child: Table(
              columnWidths: <int, TableColumnWidth>{
                0: const IntrinsicColumnWidth(), // NO
                1: const IntrinsicColumnWidth(), // HARI
                2: const IntrinsicColumnWidth(), // JAM
                3: const IntrinsicColumnWidth(), // KELAS
                4: const FlexColumnWidth(1.5), // MAPEL - lebih fleksibel
                5: isMobile ? const FixedColumnWidth(120) : const FlexColumnWidth(2), // GURU - fleksibel di layar lebar
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'NO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'HARI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'JAM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'KELAS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'MAPEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'GURU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...List.generate(tableData.length, (index) {
                  final data = tableData[index];
                  final isEvenRow = index % 2 == 0;
                  final isTodayClass = data['isTodayClass'] == true;
                  final isCurrentClass = data['isCurrentClass'] == true;
                  final isTomorrowClass = data['isTomorrowClass'] == true;
                  final isDayAfterTomorrowClass = data['isDayAfterTomorrowClass'] == true;
                  
                  // Use bg color based on class status
                  Color bgColor;
                  if (isCurrentClass) {
                    bgColor = Colors.green.withOpacity(0.1);
                  } else if (isTodayClass) {
                    bgColor = Colors.orange.withOpacity(0.05);
                  } else if (isTomorrowClass) {
                    bgColor = Colors.blueGrey.withOpacity(0.05);
                  } else if (isDayAfterTomorrowClass) {
                    bgColor = Colors.grey.withOpacity(0.05);
                  } else {
                    bgColor = isEvenRow ? Colors.white : Colors.grey.shade50;
                  }

                  final mapelText = data['mapel'].toString();
                  bool mapelIsPJOK = mapelText.trim().toUpperCase() == 'PJOK'; 

                  return TableRow(
                    decoration: BoxDecoration(
                      color: bgColor,
                    ),
                    children: [
                      // NO
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCurrentClass)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else if (isTodayClass)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else if (isTomorrowClass)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.blueGrey,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else if (isDayAfterTomorrowClass)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              data['no'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF424242),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // HARI
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            // Adjust border logic to use status flags directly
                            border: isCurrentClass
                                ? Border.all(color: Colors.green) // Berlangsung border
                                : isTodayClass
                                    ? Border.all(color: Colors.orange) // Hari Ini border
                                    : isTomorrowClass
                                        ? Border.all(color: Colors.blueGrey) // Besok border
                                        : isDayAfterTomorrowClass
                                            ? Border.all(color: Colors.grey) // Lusa border
                                            : null, // Default no border
                          ),
                          child: Text(
                            (data['hari'] as String).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              // Adjust text color based on status flags
                              color: isCurrentClass
                                  ? Colors.green // Berlangsung text color
                                  : isTodayClass
                                      ? Colors.orange // Hari Ini text color
                                      : isTomorrowClass
                                          ? Colors.blueGrey // Besok text color
                                          : isDayAfterTomorrowClass
                                              ? Colors.grey // Lusa text color
                                              : const Color(0xFF2196F3), // Default text color
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // JAM
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          data['jam'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            // Adjust text color based on status flags
                            color: isCurrentClass
                                ? Colors.green
                                : isTodayClass
                                    ? Colors.orange
                                    : isTomorrowClass
                                        ? Colors.blueGrey
                                        : isDayAfterTomorrowClass
                                            ? Colors.grey
                                            : const Color(0xFF424242),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // KELAS
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          data['kelas'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            // Adjust text color based on status flags
                            color: isCurrentClass
                                ? Colors.green
                                : isTodayClass
                                    ? Colors.orange
                                    : isTomorrowClass
                                        ? Colors.blueGrey
                                        : isDayAfterTomorrowClass
                                            ? Colors.grey
                                            : const Color(0xFF424242),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // MAPEL
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          mapelText.isNotEmpty
                              ? (mapelIsPJOK ? 'PJOK' : mapelText)
                              : '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            // Adjust text color based on status flags
                            color: isCurrentClass
                                ? Colors.green
                                : isTodayClass
                                    ? Colors.orange
                                    : isTomorrowClass
                                        ? Colors.blueGrey
                                        : isDayAfterTomorrowClass
                                            ? Colors.grey
                                            : const Color(0xFF424242),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // GURU
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          data['guru'].toString().isNotEmpty
                              ? data['guru']
                              : '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            // Adjust text color based on status flags
                            color: isCurrentClass
                                ? Colors.green
                                : isTodayClass
                                    ? Colors.orange
                                    : isTomorrowClass
                                        ? Colors.blueGrey
                                        : isDayAfterTomorrowClass
                                            ? Colors.grey
                                            : const Color(0xFF424242),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }
    );
  }
}

// Tambahkan kelas untuk card aksi cepat dengan style baru
class _QuickActionCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2196F3).withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, height: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Keep original components only
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

class _HomeMenuCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _HomeMenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, height: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}