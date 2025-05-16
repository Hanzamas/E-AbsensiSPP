import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/strings.dart';

class ProfileEditPage extends StatefulWidget {
  final bool isFromLogin;
  const ProfileEditPage({Key? key, this.isFromLogin = false}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _storage = const FlutterSecureStorage();

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _jenisKelaminController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _waliController = TextEditingController();
  final TextEditingController _waWaliController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  int? _studentId;

  // Dropdown kelas
  List<Map<String, dynamic>> _kelasList = [];
  String? _selectedKelasId;

  bool _isProfileCompleted = false;

  @override
  void initState() {
    super.initState();
    _initProfile();
    if (widget.isFromLogin) {
      _checkAndShowWelcomePopup();
    }
  }

  Future<void> _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPopup = prefs.getBool('has_shown_profile_popup') ?? false;

    if (!hasShownPopup && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Login Berhasil'),
          content: const Text('Selamat datang! Silakan lengkapi data diri Anda terlebih dahulu.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Save that we've shown the popup
                await prefs.setBool('has_shown_profile_popup', true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      if (mounted) context.go('/login');
      return;
    }
    setState(() {
      _token = token;
    });
    await _fetchKelas(token);
    await _fetchProfile(token);
  }

  Future<void> _fetchKelas(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getKelas),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        final List kelas = data['data'];
        setState(() {
          _kelasList = kelas.map<Map<String, dynamic>>((k) => {
            'id': k['id'],
            'nama': k['nama'],
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchProfile(String token) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // First get user profile to get user ID
      final profileResponse = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // print('Profile Response: ${profileResponse.body}'); // Debug log
      final profileData = jsonDecode(profileResponse.body);
      
      if (profileResponse.statusCode == 200 && profileData['status'] == true) {
        final userId = profileData['data']['id'];
        // print('User ID: $userId'); // Debug log
        
        // Check if profile is completed by checking if siswa_nama_lengkap exists
        final isProfileCompleted = profileData['data']['siswa_nama_lengkap'] != null;
        // print('Is Profile Completed: $isProfileCompleted'); // Debug log
        
        if (isProfileCompleted) {
          // If profile is completed, get student data
          final studentResponse = await http.get(
            Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getStudentDetail}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          // print('Student Response: ${studentResponse.body}'); // Debug log
          final studentData = jsonDecode(studentResponse.body);
          
          if (studentResponse.statusCode == 200 && studentData['status'] == true) {
            if (studentData['data'] == null) {
              setState(() {
                _errorMessage = 'Data siswa tidak ditemukan';
                _isProfileCompleted = false;
              });
              return;
            }
            
            final student = studentData['data'];
            // print('Student Data: $student'); // Debug log
            
            setState(() {
              _studentId = student['id'];
              _namaLengkapController.text = student['nama_lengkap'] ?? '';
              _nisController.text = student['nis'] ?? '';
              _selectedKelasId = student['id_kelas']?.toString();
              _jenisKelaminController.text = student['jenis_kelamin'] ?? '';
              _setTanggalLahir(student['tanggal_lahir'] ?? '');
              _tempatLahirController.text = student['tempat_lahir'] ?? '';
              _alamatController.text = student['alamat'] ?? '';
              _waliController.text = student['wali'] ?? '';
              _waWaliController.text = student['wa_wali'] ?? '';
              _isProfileCompleted = true;
            });
          } else {
            // print('Student Error: ${studentData['message']}'); // Debug log
            setState(() {
              _errorMessage = studentData['message'] ?? 'Gagal mengambil data siswa';
              _isProfileCompleted = false;
            });
          }
        } else {
          // If profile is not completed, just set the profile data
          setState(() {
            _isProfileCompleted = false;
            // Clear all fields since this is a new profile
            _namaLengkapController.text = '';
            _nisController.text = '';
            _selectedKelasId = null;
            _jenisKelaminController.text = '';
            _tanggalLahirController.text = '';
            _tempatLahirController.text = '';
            _alamatController.text = '';
            _waliController.text = '';
            _waWaliController.text = '';
          });
        }
      } else {
        // print('Profile Error: ${profileData['message']}'); // Debug log
        if (profileData['message']?.toString().toLowerCase().contains('token') ?? false) {
          if (mounted) context.go('/login');
          return;
        }
        setState(() {
          _errorMessage = profileData['message'] ?? 'Gagal mengambil data profil';
        });
      }
    } catch (e) {
      // print('Exception: $e'); // Debug log
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validasi semua field wajib
    if (_selectedKelasId == null) {
      setState(() {
        _errorMessage = 'Kelas harus dipilih!';
        _isLoading = false;
      });
      return;
    }

    if (_nisController.text.isEmpty) {
      setState(() {
        _errorMessage = 'NIS tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_namaLengkapController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Nama lengkap tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_jenisKelaminController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Jenis kelamin tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_tanggalLahirController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tanggal lahir tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_tempatLahirController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tempat lahir tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_alamatController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Alamat tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_waliController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Nama wali tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    if (_waWaliController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Nomor WA wali tidak boleh kosong!';
        _isLoading = false;
      });
      return;
    }

    try {
      // Get user ID first
      final profileResponse = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      final profileData = jsonDecode(profileResponse.body);
      
      if (profileResponse.statusCode != 200 || !profileData['status']) {
        throw Exception(profileData['message'] ?? 'Gagal mendapatkan ID pengguna');
      }

      final userId = profileData['data']['id'];
      
      // Format tanggal_lahir ke YYYY-MM-DD
      String formattedDate = _tanggalLahirController.text;
      if (formattedDate.contains('T')) {
        formattedDate = formattedDate.split('T')[0];
      }
      
      // Siapkan payload update dengan semua field
      final updatePayload = {
        'id_kelas': int.parse(_selectedKelasId!),
        'nis': _nisController.text.trim(),
        'nama_lengkap': _namaLengkapController.text.trim(),
        'jenis_kelamin': _jenisKelaminController.text.trim(),
        'tanggal_lahir': formattedDate,
        'tempat_lahir': _tempatLahirController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'wali': _waliController.text.trim(),
        'wa_wali': _waWaliController.text.trim(),
      };

      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(updatePayload),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        if (!mounted) return;
        
        // Tampilkan popup sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Jika ini update pertama kali (profile completion)
        if (!_isProfileCompleted) {
          context.go('/profile-success');
        } else {
          context.go('/profile');
        }
      } else if (data['message']?.toString().toLowerCase().contains('token') ?? false) {
        if (mounted) context.go('/login');
        return;
      } else {
        // Tampilkan popup error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mengupdate profil'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal mengupdate profil';
        });
      }
    } catch (e) {
      // Tampilkan popup error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this method to format date when setting the controller
  void _setTanggalLahir(String date) {
    if (date.contains('T')) {
      date = date.split('T')[0];
    }
    _tanggalLahirController.text = date;
  }

  Widget _inputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isProfileCompleted) {
          context.go('/profile');
          return false;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.EditProfileTitle),
          leading: _isProfileCompleted ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/profile');
            },
          ) : null,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipOval(
                        child: Builder(
                          builder: (context) {
                              return Container(
                                color: Colors.blue[100],
                                child: const Icon(Icons.person, size: 60, color: Colors.white),
                              );
                            }
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    _inputContainer(
                      child: DropdownButtonFormField<String>(
                        value: _selectedKelasId,
                        items: _kelasList.map((kelas) {
                          return DropdownMenuItem<String>(
                            value: kelas['id'].toString(),
                            child: Text(kelas['nama']),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedKelasId = val),
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.class_),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _nisController,
                        decoration: const InputDecoration(
                          hintText: 'NIS',
                          prefixIcon: Icon(Icons.confirmation_number),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _namaLengkapController,
                        decoration: const InputDecoration(
                          hintText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: DropdownButtonFormField<String>(
                        value: _jenisKelaminController.text.isNotEmpty ? _jenisKelaminController.text : null,
                        items: const [
                          DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _jenisKelaminController.text = val ?? '';
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          prefixIcon: Icon(Icons.wc),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime firstDate = DateTime(1999);
                          DateTime lastDate = DateTime(DateTime.now().year, 12, 31);
                          DateTime initialDate;
                          if (_tanggalLahirController.text.isNotEmpty) {
                            final parsed = DateTime.tryParse(_tanggalLahirController.text);
                            if (parsed != null && !parsed.isBefore(firstDate) && !parsed.isAfter(lastDate)) {
                              initialDate = parsed;
                            } else {
                              initialDate = lastDate;
                            }
                          } else {
                            initialDate = lastDate;
                          }
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: firstDate,
                            lastDate: lastDate,
                          );
                          if (picked != null) {
                            setState(() {
                              _tanggalLahirController.text = picked.toIso8601String().split('T')[0];
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Tanggal Lahir',
                          prefixIcon: Icon(Icons.cake),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _tempatLahirController,
                        decoration: const InputDecoration(
                          hintText: 'Tempat Lahir',
                          prefixIcon: Icon(Icons.location_city),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(
                          hintText: 'Alamat',
                          prefixIcon: Icon(Icons.home),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _waliController,
                        decoration: const InputDecoration(
                          hintText: 'Nama Wali',
                          prefixIcon: Icon(Icons.people),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    _inputContainer(
                      child: TextFormField(
                        controller: _waWaliController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'No. WA Wali',
                          prefixIcon: Icon(Icons.phone),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor WA wali tidak boleh kosong!';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Nomor WA hanya boleh angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                Strings.EditProfileButton,
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
      ),
    );
  }
}
