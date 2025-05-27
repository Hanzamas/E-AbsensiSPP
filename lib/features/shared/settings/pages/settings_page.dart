import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SettingsPage extends StatefulWidget {
  final String userRole;
  
  const SettingsPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  final List<String> _availableLanguages = ['Indonesia', 'English'];
  final List<String> _availableTextSizes = ['Kecil', 'Normal', 'Besar'];

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Tidak tersedia';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/${widget.userRole}/profile'),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.isLoading;
          
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingSection(
                        title: 'Tampilan',
                        children: [
                          SwitchListTile(
                            title: const Text('Mode Gelap'),
                            subtitle: const Text('Menghemat baterai dan mengurangi ketegangan mata'),
                            value: provider.isDarkMode,
                            onChanged: (value) {
                              provider.isDarkMode = value;
                            },
                            secondary: const Icon(Icons.dark_mode, color: Colors.purple),
                          ),
                          ListTile(
                            title: const Text('Ukuran Teks'),
                            subtitle: Text(provider.textSize),
                            leading: const Icon(Icons.format_size, color: Colors.blue),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Ukuran Teks'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _availableTextSizes.length,
                                      itemBuilder: (context, index) {
                                        final size = _availableTextSizes[index];
                                        return RadioListTile<String>(
                                          title: Text(size),
                                          value: size,
                                          groupValue: provider.textSize,
                                          onChanged: (value) {
                                            Navigator.pop(context);
                                            if (value != null) {
                                              provider.textSize = value;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      _buildSettingSection(
                        title: 'Notifikasi',
                        children: [
                          SwitchListTile(
                            title: const Text('Notifikasi'),
                            subtitle: const Text('Aktifkan semua notifikasi'),
                            value: provider.isNotificationEnabled,
                            onChanged: (value) {
                              provider.isNotificationEnabled = value;
                            },
                            secondary: const Icon(Icons.notifications, color: Colors.amber),
                          ),
                          Visibility(
                            visible: provider.isNotificationEnabled,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('Notifikasi SPP'),
                                    subtitle: const Text('Pengingat jatuh tempo dan pembayaran'),
                                    value: provider.isSPPNotificationEnabled,
                                    onChanged: provider.isNotificationEnabled 
                                        ? (value) {
                                            provider.isSPPNotificationEnabled = value;
                                          }
                                        : null,
                                    secondary: const Icon(Icons.payment, color: Colors.green),
                                  ),
                                  SwitchListTile(
                                    title: const Text('Notifikasi Absensi'),
                                    subtitle: const Text('Informasi kehadiran dan keterlambatan'),
                                    value: provider.isAttendanceNotificationEnabled,
                                    onChanged: provider.isNotificationEnabled 
                                        ? (value) {
                                            provider.isAttendanceNotificationEnabled = value;
                                          }
                                        : null,
                                    secondary: const Icon(Icons.assignment_turned_in, color: Colors.teal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildSettingSection(
                        title: 'Keamanan',
                        children: [
                          SwitchListTile(
                            title: const Text('Logout Otomatis'),
                            subtitle: const Text('Keluar otomatis setelah 30 menit tidak aktif'),
                            value: provider.isAutoLogoutEnabled,
                            onChanged: (value) {
                              provider.isAutoLogoutEnabled = value;
                            },
                            secondary: const Icon(Icons.timer, color: Colors.orange),
                          ),
                          ListTile(
                            title: const Text('Ubah Kata Sandi'),
                            subtitle: const Text('Perbaharui kata sandi akun'),
                            leading: const Icon(Icons.password, color: Colors.red),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.push('/${widget.userRole}/profile/edit-account'),
                          ),
                        ],
                      ),
                      _buildSettingSection(
                        title: 'Bahasa',
                        children: [
                          ListTile(
                            title: const Text('Bahasa'),
                            subtitle: Text(provider.language),
                            leading: const Icon(Icons.language, color: Colors.blue),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Pilih Bahasa'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _availableLanguages.length,
                                      itemBuilder: (context, index) {
                                        final language = _availableLanguages[index];
                                        return RadioListTile<String>(
                                          title: Text(language),
                                          value: language,
                                          groupValue: provider.language,
                                          onChanged: (value) {
                                            Navigator.pop(context);
                                            if (value != null) {
                                              provider.language = value;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      _buildSettingSection(
                        title: 'Data dan Penyimpanan',
                        children: [
                          ListTile(
                            title: const Text('Hapus Cache'),
                            subtitle: const Text('Bersihkan data sementara aplikasi'),
                            leading: const Icon(Icons.cleaning_services, color: Colors.cyan),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Cache'),
                                  content: const Text(
                                    'Ini akan membersihkan data cache aplikasi. Tidak akan mempengaruhi data akun atau pengaturan Anda.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Cache berhasil dihapus'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text('Reset Aplikasi'),
                            subtitle: const Text('Kembalikan ke pengaturan awal'),
                            leading: const Icon(Icons.restore, color: Colors.red),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Reset Aplikasi'),
                                  content: const Text(
                                    'Anda yakin ingin mereset semua pengaturan aplikasi? Ini akan menghapus cache dan mengembalikan pengaturan ke nilai awal, namun tidak mempengaruhi data akun Anda.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await provider.resetSettings();
                                        
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Pengaturan berhasil direset'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      _buildSettingSection(
                        title: 'Tentang',
                        children: [
                          ListTile(
                            title: const Text('Versi Aplikasi'),
                            subtitle: Text(_appVersion),
                            leading: const Icon(Icons.info_outline, color: Colors.blue),
                          ),
                          ListTile(
                            title: const Text('Tentang Kami'),
                            subtitle: const Text('Informasi pengembang dan sekolah'),
                            leading: const Icon(Icons.groups, color: Colors.green),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showAboutDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSettingSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2196F3),
            ),
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Kami'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF2196F3),
                    child: Icon(Icons.school, size: 60, color: Colors.white),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'E-AbsensiSPP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi E-AbsensiSPP dirancang untuk memudahkan pencatatan kehadiran dan pembayaran SPP di sekolah. '
                'Aplikasi ini dikembangkan untuk membantu sekolah dalam mengelola administrasi siswa secara efisien.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tim Pengembang:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('• Nama Pengembang 1 - Frontend Developer'),
              const Text('• Nama Pengembang 2 - Backend Developer'),
              const SizedBox(height: 16),
              const Text(
                'Kontak:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Email: support@eabsensispp.com'),
              const Text('Website: www.eabsensispp.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}