import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/strings.dart';

class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({Key? key}) : super(key: key);

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.person,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(Strings.ProfileTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final isLoading = provider.isLoading;
            final errorMessage = provider.error;
            final nama = provider.nama;
            final email = provider.email;
            final userRole = 'siswa'; // Hardcoded for simplicity
            
            return Center(
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
                          child: Container(
                            color: Colors.blue[100],
                            child: const Icon(Icons.person, size: 80, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else if (errorMessage != null)
                        Text(errorMessage, style: const TextStyle(color: Colors.red))
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
                          onPressed: () => context.go('/student/profile/edit'),
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
                          onPressed: () async {
                            // Logout menggunakan profile provider
                            await provider.logout();
                            if (mounted) {
                              context.go('/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
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
            );
          }
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3, // Profile index
        userRole: 'siswa',
        context: context,
      ),
    );
  }
} 