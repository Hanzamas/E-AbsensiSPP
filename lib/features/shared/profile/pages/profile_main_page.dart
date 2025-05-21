import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/strings.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileMainPage extends StatefulWidget {
  final String userRole;
  const ProfileMainPage({Key? key, required this.userRole}) : super(key: key);

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
            final profilePictureUrl = provider.profilePictureUrl;
            final userRole = widget.userRole; // Use the userRole from the widget
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Avatar dengan gambar dari API jika tersedia
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: ClipOval(
                              child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                                ? Image.network(
                                    profilePictureUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue[100],
                                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.blue[100],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.blue[100],
                                    child: const Icon(Icons.person, size: 80, color: Colors.white),
                                  ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              // Buka dialog pilihan kamera atau galeri
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo_camera),
                                          title: const Text('Ambil foto'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(ImageSource.camera, provider);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.photo_library),
                                          title: const Text('Pilih dari galeri'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(ImageSource.gallery, provider);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
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
                          onPressed: () => context.go('/${widget.userRole}/profile/edit'),
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
                      
                      // Tombol Edit Akun
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/${widget.userRole}/profile/edit-account');
                          },
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
                              Text('Edit Akun', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      
                      // Tombol Tutorial
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Tampilkan tutorial aplikasi
                            _showTutorialDialog(context);
                          },
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
                              Text('Tutorial', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      
                      // Tombol Tentang Aplikasi
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Tampilkan informasi tentang aplikasi
                            _showAboutAppDialog(context);
                          },
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
                              Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      
                      // Tombol Tentang Kami
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Tampilkan informasi tentang pengembang
                            _showAboutUsDialog(context);
                          },
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
                              Text('Tentang Kami', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              Icon(Icons.arrow_forward, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      
                      // Tombol Pengaturan
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/${widget.userRole}/settings');
                          },
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
        userRole: widget.userRole,
        context: context,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, ProfileProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mengupload foto...'),
              ],
            ),
          );
        },
      );
      
      // Upload image
      final result = await provider.uploadProfilePicture(image.path);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result 
            ? 'Foto profil berhasil diupload' 
            : 'Gagal mengupload foto profil: ${provider.error ?? "Terjadi kesalahan"}'),
          backgroundColor: result ? Colors.green : Colors.red,
        ));
      }
    }
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tutorial Aplikasi'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _tutorialItem(
                  icon: Icons.home,
                  title: 'Halaman Utama',
                  description: 'Melihat informasi jadwal dan pengumuman terbaru.',
                ),
                const SizedBox(height: 16),
                _tutorialItem(
                  icon: Icons.article_outlined,
                  title: 'Absensi',
                  description: 'Scan QR code untuk melakukan absensi harian.',
                ),
                const SizedBox(height: 16),
                _tutorialItem(
                  icon: Icons.credit_card,
                  title: 'SPP',
                  description: 'Lihat status pembayaran SPP bulanan dan riwayat transaksi.',
                ),
                const SizedBox(height: 16),
                _tutorialItem(
                  icon: Icons.person,
                  title: 'Profil',
                  description: 'Update informasi profil dan pengaturan akun.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _tutorialItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Image.asset(
                'assets/images/logo.png', // Ganti dengan path logo aplikasi
                height: 80,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.blue.withOpacity(0.1),
                    child: const Text(
                      'E-AbsensiSPP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'E-AbsensiSPP v1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi manajemen absensi dan pembayaran SPP untuk sekolah.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fitur:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Absensi siswa dengan QR Code\n'
                '• Manajemen pembayaran SPP\n'
                '• Laporan akademik\n'
                '• Informasi jadwal pelajaran',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Hak Cipta © 2023',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
            context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Kami'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.school,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'E-AbsensiSPP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dikembangkan oleh Tim Sekolah Digital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi ini dikembangkan untuk memudahkan proses absensi dan pembayaran SPP di sekolah, dengan memanfaatkan teknologi terkini untuk memberikan pengalaman yang lebih baik bagi siswa, guru, dan staff administrasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hubungi Kami:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.email, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'support@e-absensi.com',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.phone, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    '(021) 1234-5678',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
} 