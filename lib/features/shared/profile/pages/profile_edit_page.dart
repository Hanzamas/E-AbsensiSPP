import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../data/models/student_profile_model.dart';
import '../data/models/teacher_profile_model.dart';

class ProfileEditPage extends StatefulWidget {
  final bool isFromLogin;
  final String userRole;
  const ProfileEditPage({Key? key, this.isFromLogin = false, required this.userRole}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isProfileCompleted = false;
  bool _isLoading = false;
  bool _isInitialLoading = true; // State loading awal
  bool _isDataFetched = false; // Flag apakah data sudah diambil

  // Field bertipe int untuk masing-masing role (ambil dari model agar scalable)
  static final List<String> studentIntFields = StudentProfile.intFields;
  static final List<String> teacherIntFields = [];

  // Modular gender options
  static const List<Map<String, String>> genderOptions = [
    {'value': 'L', 'label': 'Laki-laki'},
    {'value': 'P', 'label': 'Perempuan'},
  ];

  @override
  void initState() {
    super.initState();
    // Gunakan singleton pattern
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    try {
      // Gunakan singleton pattern untuk fetch data
      await ProfileProvider().fetchProfileAndClasses(widget.userRole);
      
      // Inisialisasi controller setelah data tersedia
      _initControllers();
      
      // Cek apakah perlu menampilkan welcome popup
      final isSiswa = widget.userRole == 'siswa';
      final data = isSiswa 
          ? ProfileProvider().studentProfile 
          : ProfileProvider().teacherProfile;
          
      if (_shouldShowWelcomePopup(data)) {
        _showWelcomePopup();
      }
      
      _isDataFetched = true;
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  void _initControllers() {
    final provider = ProfileProvider();
    final isSiswa = widget.userRole == 'siswa';
    final data = isSiswa ? provider.studentProfile : provider.teacherProfile;
    
    if (data == null) return;
    
    // Inisialisasi controller dari data
    final map = isSiswa
        ? (provider.studentProfile as StudentProfile).toJson()
        : (provider.teacherProfile as TeacherProfile).toJson();
    
    map.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
    
    // Inisialisasi controller tahun_ajaran jika belum ada
    if (_controllers['tahun_ajaran'] == null) {
      String tahunAjaran = '';
      if (isSiswa && _controllers['id_kelas']?.text.isNotEmpty == true) {
        tahunAjaran = provider.getTahunAjaranByClassId(int.tryParse(_controllers['id_kelas']!.text)) ?? '';
      }
      _controllers['tahun_ajaran'] = TextEditingController(text: tahunAjaran);
    }
  }

  bool _shouldShowWelcomePopup(dynamic data) {
    if (data == null) return true;
    if (data is StudentProfile) {
      return data.namaLengkap.isEmpty || data.idKelas == 0;
    }
    if (data is TeacherProfile) {
      return data.namaLengkap.isEmpty;
    }
    return true;
  }

  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('Selamat Datang', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Silakan lengkapi data diri Anda terlebih dahulu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: widget.isFromLogin 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/${widget.userRole}/profile'),
              ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Gunakan Consumer untuk mendapatkan update dari provider
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final isSiswa = widget.userRole == 'siswa';
        final data = isSiswa ? provider.studentProfile : provider.teacherProfile;
        
        // Jika masih dalam initial loading, tampilkan skeleton loading
        if (_isInitialLoading) {
          return _buildSkeletonLoading(isSiswa);
        }
        
        // Jika error atau data tidak ditemukan
        if (!_isDataFetched || data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Data profil tidak ditemukan'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        
        // Inisialisasi controller jika belum dilakukan
        if (_controllers.isEmpty) {
          _initControllers();
        }
        
        // Tampilkan form data
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isSiswa) ...[
                    _buildStyledClassDropdown(),
                    _buildStyledField('nis', 'NIS', keyboardType: TextInputType.number),
                    _buildStyledField('nama_lengkap', 'Nama Lengkap'),
                    _buildStyledDropdown('jenis_kelamin', 'Jenis Kelamin'),
                    _buildStyledDateField(),
                    _buildStyledField('tempat_lahir', 'Tempat Lahir'),
                    _buildStyledField('alamat', 'Alamat'),
                    _buildStyledField('wali', 'Nama Wali'),
                    _buildStyledField('wa_wali', 'No. WA Wali', keyboardType: TextInputType.phone),
                  ] else ...[
                    _buildStyledField('nip', 'NIP'),
                    _buildStyledField('nama_lengkap', 'Nama Lengkap'),
                    _buildStyledDropdown('jenis_kelamin', 'Jenis Kelamin'),
                    _buildStyledDateField(),
                    _buildStyledField('tempat_lahir', 'Tempat Lahir'),
                    _buildStyledField('alamat', 'Alamat'),
                    _buildStyledField('pendidikan_terakhir', 'Pendidikan Terakhir'),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                await _saveProfile();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Skeleton loading untuk UI saat data sedang dimuat
  Widget _buildSkeletonLoading(bool isSiswa) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < (isSiswa ? 9 : 7); i++) 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final isSiswa = widget.userRole == 'siswa';
      final intFields = isSiswa ? StudentProfile.intFields : TeacherProfile.intFields;
      
      final payload = <String, dynamic>{};
      _controllers.forEach((key, ctrl) {
        final text = ctrl.text.trim();
        if (intFields.contains(key)) {
          // Konversi ke integer untuk field yang seharusnya integer
          payload[key] = text.isEmpty ? null : int.tryParse(text);
        } else {
          payload[key] = text;
        }
      });

      // Format tanggal lahir ke YYYY-MM-DD jika dalam format ISO
      final tanggalLahir = payload['tanggal_lahir']?.toString();
      if (tanggalLahir != null && tanggalLahir.contains('T')) {
        payload['tanggal_lahir'] = tanggalLahir.split('T')[0];
      }

      // Gunakan singleton untuk update
      final success = await ProfileProvider().updateProfile(widget.userRole, payload);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (widget.isFromLogin) {
          context.go('/profile-success');
        } else {
          context.go('/${widget.userRole}/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Semua widget _buildStyled tetap sama
  Widget _buildStyledField(String key, String label, {TextInputType? keyboardType}) {
    // Kode yang sama dengan sebelumnya
    final iconMap = <String, IconData>{
      'id_kelas': Icons.class_,
      'nis': Icons.badge_outlined,
      'nama_lengkap': Icons.person_outline,
      'nip': Icons.badge_outlined,
      'jenis_kelamin': Icons.wc,
      'tanggal_lahir': Icons.cake_outlined,
      'tempat_lahir': Icons.location_on_outlined,
      'alamat': Icons.home_outlined,
      'wali': Icons.family_restroom,
      'wa_wali': Icons.phone_outlined,
      'pendidikan_terakhir': Icons.school_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
          controller: _controllers[key],
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            hintText: key == 'wa_wali' ? '628xxxxxxxxxx' : label,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: iconMap[key] != null ? Icon(iconMap[key], color: const Color(0xFF2196F3)) : null,
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
              return '$label wajib diisi';
            }
            if (key == 'wa_wali') {
              if (!val.startsWith('62')) {
                return 'Nomor WA harus diawali dengan 62';
              }
              if (!RegExp(r'^62[0-9]{9,13}$').hasMatch(val)) {
                return 'Format nomor WA tidak valid';
              }
            }
            if (key == 'nis' && !RegExp(r'^[0-9]+$').hasMatch(val)) {
              return 'NIS harus berupa angka';
            }
            return null;
          },
          onChanged: (value) {
            if (key == 'wa_wali') {
              // Hanya izinkan angka dan awalan 62
              if (value.isNotEmpty && !value.startsWith('62')) {
                _controllers[key]?.text = '62${value.replaceAll(RegExp(r'[^0-9]'), '')}';
              } else {
                _controllers[key]?.text = value.replaceAll(RegExp(r'[^0-9]'), '');
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildStyledDropdown(String key, String label) {
    // Gunakan kode yang sama dengan sebelumnya
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
        child: DropdownButtonFormField<String>(
          value: _controllers[key]?.text.isNotEmpty == true ? _controllers[key]?.text : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: key == 'jenis_kelamin' ? const Icon(Icons.wc, color: Color(0xFF2196F3)) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: genderOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              _controllers[key]?.text = val;
            }
          },
          validator: (val) => val == null ? '$label wajib dipilih' : null,
        ),
      ),
    );
  }

  Widget _buildStyledDateField() {
    // Gunakan kode yang sama dengan sebelumnya
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
          controller: _controllers['tanggal_lahir'],
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Lahir',
            hintText: 'Tanggal Lahir',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF2196F3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              _controllers['tanggal_lahir']?.text = picked.toIso8601String().split('T')[0];
            }
          },
          validator: (val) => (val == null || val.isEmpty) ? 'Tanggal lahir wajib diisi' : null,
        ),
      ),
    );
  }

  Widget _buildStyledClassDropdown() {
    // Gunakan singleton pattern untuk konsistensi
    final provider = ProfileProvider();
    
    if (provider.isLoadingClasses) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
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
            child: DropdownButtonFormField<int>(
              value: _controllers['id_kelas']?.text.isNotEmpty == true 
                  ? int.tryParse(_controllers['id_kelas']!.text) 
                  : null,
              decoration: InputDecoration(
                labelText: 'Kelas',
                hintText: 'Pilih Kelas',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.class_, color: Color(0xFF2196F3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: provider.classes.map((kelas) {
                return DropdownMenuItem<int>(
                  value: kelas.id,
                  child: Text(kelas.namaKelas),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  _controllers['id_kelas']?.text = val.toString();
                  // Update tahun ajaran jika ada
                  final tahunAjaran = provider.getTahunAjaranByClassId(val);
                  if (tahunAjaran != null) {
                    _controllers['tahun_ajaran']?.text = tahunAjaran;
                  }
                }
              },
              validator: (val) => val == null ? 'Kelas wajib dipilih' : null,
            ),
          ),
        ),
        // Tahun Ajaran (Read-only)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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
              controller: _controllers['tahun_ajaran'],
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Tahun Ajaran',
                hintText: 'Pilih Kelas terlebih dahulu',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}