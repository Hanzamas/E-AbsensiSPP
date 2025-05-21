import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_absensi/core/constants/strings.dart';
import 'package:e_absensi/core/constants/assets.dart';
import 'package:e_absensi/features/shared/auth/provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          final role = authProvider.userRole;
          final isProfileCompleted = authProvider.userData?.isProfileCompleted ?? false;

          // Komentari bagian pengecekan profil
          /* 
          if (!isProfileCompleted) {
            _showDialog(
              'Login Berhasil',
              'Selamat datang! Silakan lengkapi profil Anda terlebih dahulu.',
              onOk: () {
                context.goNamed('profile-first-input');
              },
            );
            return;
          }
          */

          // Tambahkan delay untuk memastikan snackbar terlihat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${authProvider.userData?.username ?? ""}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!mounted) return;

          switch (role?.toLowerCase()) {
            case 'siswa':
              context.goNamed('student-home');
              break;
            case 'guru':
              context.goNamed('teacher-home');
              break;
            case 'admin':
              context.goNamed('admin-home');
              break;
            default:
              _showError('Role tidak valid: ${role ?? "tidak diketahui"}');
          }
        } else {
          _showError('Gagal login: Status tidak berhasil');
        }
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.contains('401') || errorMessage.contains('unauthorized')) {
          errorMessage = 'Username atau password salah';
        } else if (errorMessage.contains('not found') || errorMessage.contains('tidak ditemukan')) {
          errorMessage = 'Akun tidak ditemukan';
        } else if (errorMessage.contains('validation') || errorMessage.contains('validasi')) {
          errorMessage = 'Username atau password tidak valid';
        } else {
          errorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti. (${e.toString()})';
        }
        _showError(errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    Assets.logo,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.loginTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Input Email
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: Strings.usernameHint,
                        prefixIcon: Icon(Icons.person_outline),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Strings.emailHint;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input Password
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: Strings.passwordHint,
                        prefixIcon: Icon(Icons.lock_outline),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Strings.passwordHint;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.goNamed('forgot-password'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        Strings.forgotPassword,
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              Strings.loginButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: Strings.noAccount,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: Strings.registerLink,
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.goNamed('register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: Strings.agreeText,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: Strings.termsText,
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.goNamed('terms', extra: 'login'),
                          ),
                          TextSpan(
                            text: Strings.andText,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          TextSpan(
                            text: Strings.conditionsText,
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.goNamed('terms', extra: 'login'),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}