import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Tidak tersedia';
      });
    }
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
              color: Colors.blue,
            ),
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi', style: TextStyle(color: Colors.white)),
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
                        title: 'Umum',
                        children: [
                          SwitchListTile(
                            title: const Text('Notifikasi'),
                            subtitle: const Text('Aktifkan notifikasi push'),
                            value: provider.isNotificationEnabled,
                            onChanged: (value) {
                              provider.isNotificationEnabled = value;
                            },
                            secondary: const Icon(Icons.notifications),
                          ),
                          SwitchListTile(
                            title: const Text('Mode Gelap'),
                            subtitle: const Text('Gunakan tema gelap'),
                            value: provider.isDarkMode,
                            onChanged: (value) {
                              provider.isDarkMode = value;
                            },
                            secondary: const Icon(Icons.dark_mode),
                          ),
                          ListTile(
                            title: const Text('Bahasa'),
                            subtitle: Text(provider.language),
                            leading: const Icon(Icons.language),
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
                            title: const Text('Reset Aplikasi'),
                            subtitle: const Text('Hapus data cache dan pengaturan lokal'),
                            leading: const Icon(Icons.restore),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Reset Aplikasi'),
                                  content: const Text(
                                    'Anda yakin ingin mereset semua pengaturan aplikasi? Ini akan menghapus cache dan pengaturan lokal namun tidak mempengaruhi data akun Anda.',
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
                            leading: const Icon(Icons.info_outline),
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
} 