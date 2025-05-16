import 'package:flutter/material.dart';
import '../../../../core/constants/assets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/services/schedule_service.dart';
import '../../home/model/schedule.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../shared/widgets/loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api_endpoints.dart';


class StudentHomePage extends StatefulWidget {
  final String fullname;
  const StudentHomePage({Key? key, required this.fullname}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;
  List<Schedule> _weeklySchedule = [];
  bool _isLoadingSchedule = true;
  String? fullname;
  bool _isLoadingProfile = true;
  String? _profileError;
  final _storage = const FlutterSecureStorage();

  static const List<String> hariList = [
    'senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _checkAndShowWelcomePopup();
    _loadWeeklySchedule();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        setState(() {
          _profileError = 'Token tidak ditemukan';
          _isLoadingProfile = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          fullname = data['data']['siswa_nama_lengkap'] ?? data['data']['nama'] ?? '-';
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _profileError = data['message'] ?? 'Gagal mengambil data profil';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      setState(() {
        _profileError = 'Terjadi kesalahan. Coba lagi.';
        _isLoadingProfile = false;
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

  Future<void> _loadWeeklySchedule() async {
    setState(() => _isLoadingSchedule = true);
    try {
      final service = ScheduleService();
      final data = await service.getStudentSchedule();
      final List<dynamic> list = data['data'] ?? [];
      final schedule = list.map((e) => Schedule.fromJson(e)).toList();
      setState(() {
        _weeklySchedule = schedule;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        _weeklySchedule = [];
        _isLoadingSchedule = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userRole = 'siswa';
        if (state is AuthSuccess) {
          userRole = state.auth.role;
        }
        return Scaffold(
          body: Container(
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
                  Padding(
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
                                text: _isLoadingProfile
                                  ? '...'
                                  : (fullname ?? '-'),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Menu baris 1
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HomeMenuCard(
                            icon: Assets.absensi,
                            label: 'Absensi',
                            onTap: () {
                              context.go('/attendance');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _HomeMenuCard(
                            icon: Assets.spp,
                            label: 'Pembayaran Spp',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kotak besar kosong di bawah
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                          child: _isLoadingSchedule
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: FadeIn(child: DefaultLoading()),
                                )
                              : _weeklySchedule.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'Tidak ada Jadwal Kelas.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('NO')),
                                          DataColumn(label: Text('HARI')),
                                          DataColumn(label: Text('JAM')),
                                          DataColumn(label: Text('KELAS')),
                                          DataColumn(label: Text('MAPEL')),
                                          DataColumn(label: Text('GURU')),
                                        ],
                                        rows: List.generate(_weeklySchedule.length, (i) {
                                          final s = _weeklySchedule[i];
                                          String jamMulai = s.jamMulai.substring(0, 5);
                                          String jamSelesai = s.jamSelesai.substring(0, 5).replaceAll(':', '.');
                                          return DataRow(
                                            cells: [
                                              DataCell(Text((i + 1).toString())),
                                              DataCell(Text(s.hari.toUpperCase())),
                                              DataCell(Text(('$jamMulai - $jamSelesai').toUpperCase())),
                                              DataCell(Text(s.ruangKelas.toUpperCase())),
                                              DataCell(Text(s.mapel.toUpperCase())),
                                              DataCell(Text(s.guruPengajar.toUpperCase())),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: getNavIndex(userRole, '/student/home'),
            userRole: userRole,
            context: context,
          ),
        );
      },
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 80, height: 80, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
