import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_navbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../core/constants/assets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/strings.dart';

class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({Key? key}) : super(key: key);

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  String? nama;
  String? email;
  bool _isLoading = true;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = 'Token tidak ditemukan';
          _isLoading = false;
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
          nama = data['data']['siswa_nama_lengkap'] ?? data['data']['nama'] ?? '-';
          email = data['data']['email'] ?? '-';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal mengambil data profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
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
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(Strings.ProfileTitle, style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: Color(0xFF2196F3),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Avatar dengan fallback jika asset tidak ditemukan
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: ClipOval(
                          child: Builder(
                            builder: (context) {     
                                return Container(
                                  color: Colors.blue[100],
                                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                                );
                              }
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_errorMessage != null)
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red))
                      else ...[
                        Text(
                          nama ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Tombol Edit Profil
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () => context.go('/profile-edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 2,
                            minimumSize: const Size.fromHeight(70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(Strings.EditProfileButton, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      // Tombol Pengaturan
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 2,
                            minimumSize: const Size.fromHeight(70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      // Tombol Keluar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implementasi logout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: getNavIndex(userRole, '/profile'),
            userRole: userRole,
            context: context,
          ),
        );
      },
    );
  }
} 