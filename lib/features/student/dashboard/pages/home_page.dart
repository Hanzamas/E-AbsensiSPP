import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/assets.dart';
import '../../../shared/animations/fade_in_animation.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../shared/widgets/loading.dart';
import '../provider/schedule_provider.dart';
import '../data/models/schedule_model.dart';
import '../data/services/user_info_service.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;
  final UserInfoService _userInfoService = UserInfoService();

  static const List<String> hariList = [
    'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'
  ];

  @override
  void initState() {
    super.initState();
    _checkAndShowWelcomePopup();
    _loadUserInfo();
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    scheduleProvider.loadSchedules();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    setState(() { _isLoading = true; });
    try {
      await Future.wait([
        _refreshUserInfo(),
        scheduleProvider.refreshSchedules(),
      ]);
    } catch (e) {
      // ignore error, tetap pakai cache
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    
    // // Reset flag untuk testing (hapus baris ini di produksi)
    // await prefs.setBool('has_shown_welcome_popup', false);
    
    final hasShownPopup = prefs.getBool('has_shown_welcome_popup') ?? false;

    if (!hasShownPopup && mounted) {
      // Show welcome popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Login Berhasil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Selamat datang kembali!',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Save that we've shown the popup
                    await prefs.setBool('has_shown_welcome_popup', true);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _loadUserInfo() async {
    // Coba ambil dari cache dulu, jika tidak ada fetch dari API
    final data = await _userInfoService.getUserInfo();
    setState(() {
      _userInfo = data;
    });
  }

  Future<void> _refreshUserInfo() async {
    final data = await _userInfoService.refreshUserInfo();
    setState(() {
      _userInfo = data;
    });
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        userRole: 'siswa',
        context: context,
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
                _buildMenuCards(),
              const SizedBox(height: 24),
                _buildScheduleSection(),
              const SizedBox(height: 24),
              _buildReminderSection(),
              const SizedBox(height: 24),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final nama = _userInfo != null ? (_userInfo!['nama_lengkap'] ?? _userInfo!['username'] ?? '-') : '-';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan judul "Dashboard" dan icon
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

  Widget _buildMenuCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _HomeMenuCard(
              icon: Assets.absensi,
              label: 'Absensi',
              onTap: () {
                context.go('/student/attendance');
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HomeMenuCard(
              icon: Assets.spp,
              label: 'Pembayaran SPP',
              onTap: () {
                context.go('/student/spp');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;
        final schedules = provider.schedules;
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
                      Expanded(
                        child: Row(
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
                            const Flexible(
                              child: Text(
                                'Jadwal Pelajaran',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!isLoading) {
                            await provider.refreshSchedules();
                            await _refreshUserInfo();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jadwal berhasil diperbarui'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: isLoading ? Colors.grey : const Color(0xFF2196F3),
                        ),
                        tooltip: 'Perbarui jadwal',
                      ),
                      if (!isLoading && (schedules?.isNotEmpty ?? false))
                        _buildFilterDropdown(),
                    ],
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: FadeInAnimation(child: DefaultLoading()),
                  )
                else if (schedules == null || schedules.isEmpty)
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
                            'Tidak ada Jadwal Kelas.',
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
    final currentDay = [
      'minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu'
    ][now.weekday % 7];

    // Default to current day if no selection
    if (_selectedDay == '') {
      _selectedDay = currentDay;
    }

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
            child: Text('Semua hari'),
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

  Widget _buildScheduleTable(List<Schedule> schedules) {
    // Get current day and time
    final now = DateTime.now();
    final currentDay = [
      'minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu'
    ][now.weekday % 7]; // 0 = Sunday in this array to match with DateTime.weekday

    // Get tomorrow (besok) dan lusa (2 hari ke depan)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDay = [
      'minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu'
    ][tomorrow.weekday % 7];
    
    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));
    final dayAfterTomorrowDay = [
      'minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu'
    ][dayAfterTomorrow.weekday % 7];
    
    final currentTimeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Group schedules by day (we'll show all days together in a single table)
    final Map<String, List<Schedule>> schedulesMap = {};
    for (final schedule in schedules) {
      final day = schedule.hari.toLowerCase();
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
      daysToShow = hariList;
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
          bool isTodayClass = hari == currentDay;
          bool isTomorrowClass = hari == tomorrowDay;
          bool isDayAfterTomorrowClass = hari == dayAfterTomorrowDay;
          
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
            child: _buildResponsiveTable(tableData, tomorrowDay, dayAfterTomorrowDay),
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
                    border: isTodayClass
                        ? Border.all(color: const Color(0xFF2196F3))
                        : isTomorrowClass
                            ? Border.all(color: Colors.blueGrey)
                            : isDayAfterTomorrowClass
                                ? Border.all(color: Colors.grey)
                                : null,
                  ),
                  child: Text(
                    (data['hari'] as String).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: isTomorrowClass
                          ? Colors.blueGrey
                          : isDayAfterTomorrowClass
                              ? Colors.grey
                              : const Color(0xFF2196F3),
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
                    color: isCurrentClass
                        ? Colors.green
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
                    color: isTomorrowClass
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
                    color: isTomorrowClass
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
                    color: isTomorrowClass
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

  Widget _buildReminderSection() {
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
                      Icons.notifications_active,
                color: Color(0xFF2196F3),
                      size: 20,
            ),
          ),
          const SizedBox(width: 12),
                  const Text(
                    'Pengumuman Terbaru',
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event_note,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ujian Tengah Semester',
                            style: TextStyle(
                    fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'UTS akan dilaksanakan pada tanggal 15-24 Oktober 2023. Mohon persiapkan diri dengan baik.',
                      style: TextStyle(
                    fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                Text(
                          '05 Oktober 2023',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pembayaran SPP Bulan Oktober',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Batas waktu pembayaran SPP bulan Oktober adalah tanggal 10 Oktober 2023. Harap segera melakukan pembayaran.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                Text(
                          '01 Oktober 2023',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to notifications page
                  },
                  child: const Text(
                    'Lihat Semua Pengumuman',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ),
          ),
        ],
        ),
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