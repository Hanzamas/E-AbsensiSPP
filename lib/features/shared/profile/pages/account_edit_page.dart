import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class AccountEditPage extends StatefulWidget {
  final String userRole;
  
  const AccountEditPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.loadUserProfile();
    
    setState(() {
      _usernameController.text = provider.userInfo?.username ?? '';
      _emailController.text = provider.userInfo?.email ?? '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateAccount(BuildContext context, ProfileProvider provider) async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await provider.updateAccount(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal memperbarui akun'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePassword(BuildContext context, ProfileProvider provider) async {
    if (_oldPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password lama tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await provider.updatePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset form setelah berhasil
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal memperbarui password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/${widget.userRole}/profile'),
        ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Akun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
          controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: const Color(0xFF2196F3),
                  unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Profil Akun'),
            Tab(text: 'Password'),
          ],
        ),
      ),
              // Tab Content
              Expanded(
                child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.isLoading;
          
                    return TabBarView(
              controller: _tabController,
              children: [
                // Tab Edit Profil Akun
                SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                              Container(
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
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Informasi Akun',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 16),
                                          _buildStyledTextField(
                                            controller: _usernameController,
                                            label: 'Username',
                                            hintText: 'Masukkan username',
                                            icon: Icons.person_outline,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildStyledTextField(
                        controller: _emailController,
                                            label: 'Email',
                                            hintText: 'Masukkan email',
                                            icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _updateAccount(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                        ),
                        child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                            : const Text(
                                'Simpan Perubahan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                // Tab Password
                SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                              Container(
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
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ubah Password',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 16),
                                          _buildStyledTextField(
                                            controller: _oldPasswordController,
                                            label: 'Password Lama',
                                            hintText: 'Masukkan password lama',
                                            icon: Icons.lock_outline,
                                            obscureText: true,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildStyledTextField(
                        controller: _newPasswordController,
                                            label: 'Password Baru',
                                            hintText: 'Masukkan password baru',
                                            icon: Icons.lock_outline,
                        obscureText: true,
                                          ),
                                        ],
                        ),
                      ),
                                  ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _updatePassword(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                        ),
                        child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                            : const Text(
                                'Ubah Password',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                              ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  // Metode baru untuk membuat TextField yang konsisten
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
                ),
              ],
            ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2196F3),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
} 