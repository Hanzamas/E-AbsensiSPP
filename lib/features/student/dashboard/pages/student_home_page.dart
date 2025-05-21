import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/assets.dart';
import '../../../../shared/animations/fade_in.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/error_retry.dart';
import '../provider/student_provider.dart';
import '../data/models/schedule.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  static const List<String> hariList = [
    'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'
  ];

  @override
  void initState() {
    super.initState();
    _checkAndShowWelcomePopup();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final provider = Provider.of<StudentProvider>(context, listen: false);
    await Future.wait([
      provider.loadProfile(),
      provider.loadSchedule(),
    ]);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPopup = prefs.getBool('has_shown_welcome_popup') ?? false;

    if (!hasShownPopup && mounted) {
      // Show welcome popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Login Berhasil'),
              content: const Text('Selamat datang kembali!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Save that we've shown the popup
                    await prefs.setBool('has_shown_welcome_popup', true);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: getNavIndex('siswa', '/student/home'),
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
          colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMenuCards(),
            const SizedBox(height: 16),
            _buildScheduleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;
        final error = provider.error;
        final student = provider.student;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Halo, ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  children: [
                    TextSpan(
                      text: isLoading
                        ? '...'
                        : (student?.displayName ?? '-'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lihat aktivitasmu dan semoga hari harimu menyenangkan',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;
        final schedules = provider.schedules;
        final error = provider.error;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: FadeIn(child: DefaultLoading()),
                  )
                : error != null
                  ? ErrorRetry(
                      message: 'Gagal memuat jadwal: $error',
                      onRetry: _loadData,
                    )
                  : schedules.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Tidak ada Jadwal Kelas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildScheduleList(schedules),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleList(List<Schedule> schedules) {
    // Group schedules by day
    final Map<String, List<Schedule>> schedulesMap = {};
    for (final schedule in schedules) {
      final day = schedule.hari.toLowerCase();
      if (!schedulesMap.containsKey(day)) {
        schedulesMap[day] = [];
      }
      schedulesMap[day]!.add(schedule);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Pelajaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          for (final hari in hariList)
            if (schedulesMap.containsKey(hari))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hari.substring(0, 1).toUpperCase() + hari.substring(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...schedulesMap[hari]!.map((schedule) => _ScheduleItem(schedule: schedule)),
                  const SizedBox(height: 16),
                ],
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, height: 48),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleItem({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.formattedWaktu,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.mapel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guru: ${schedule.guruPengajar}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ruang: ${schedule.ruangKelas}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
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
