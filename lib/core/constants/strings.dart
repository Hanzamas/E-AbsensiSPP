class Strings {
  // App Info
  static const String appName               = 'E‑AbsensiSPP';
  static const String appDescription        = 'Aplikasi absensi SPP berbasis Flutter untuk sekolahmu.';
  
  // Login Page
  static const String loginTitle            = 'Login';
  static const String loginButton           = 'MASUK';
  static const String forgotPassword        = 'Lupa Password?';
  static const String emailHint             = 'Masukkan Email';
  static const String passwordHint          = 'Masukkan Password';
  static const String noAccount             = 'Belum punya akun? ';
  static const String registerLink          = 'Daftar';
  static const String agreeText             = 'Dengan memakai aplikasi ini, anda menyetujui ';
  static const String termsText             = '\n syarat';
  static const String andText               = ' dan ';
  static const String conditionsText        = 'ketentuan';
  static const String loginInstruction      = 'Silakan masuk untuk melanjutkan.';
  
  // Terms and Conditions
  static const String termsAndConditionsTitle = 'Syarat dan Ketentuan';
  static const String understandButton        = 'SAYA MENGERTI';
  static const String termsAndConditionsContent = '''
1. Aplikasi E-AbsensiSPP hanya dapat digunakan oleh siswa, guru, dan staf administrasi yang terdaftar.

2. Pengguna wajib menjaga kerahasiaan akun dan tidak membagikan informasi login kepada pihak lain.

3. Data yang dimasukkan ke dalam aplikasi harus benar dan dapat dipertanggungjawabkan.

4. Absensi hanya dapat dilakukan pada jam dan lokasi yang telah ditentukan.

5. Pembayaran SPP melalui aplikasi harus mengikuti prosedur yang telah ditetapkan.

6. Pengguna bertanggung jawab atas keamanan perangkat dan koneksi internet yang digunakan.

7. Pihak sekolah berhak menonaktifkan akun yang melanggar ketentuan penggunaan.

8. Data yang tersimpan dalam aplikasi menjadi hak milik sekolah.

9. Aplikasi dapat diperbarui sewaktu-waktu untuk perbaikan dan peningkatan layanan.

10. Dengan menggunakan aplikasi ini, pengguna menyetujui seluruh syarat dan ketentuan yang berlaku.
''';
  
  // Register Page
  static const String registerTitle         = 'Daftar';
  static const String registerSubtitle      = 'Silahkan masuk terlebih dahulu';
  static const String registerButton        = 'DAFTAR';
  static const String haveAccount           = 'Sudah punya akun? ';
  static const String usernameHint          = 'Masukan Username';
  static const String registeremail         = 'Masukkan Email';
  static const String registerPassword      = 'Masukkan Password';
  static const String validateEmail         = 'Masukkan email valid';
  static const String validateUsername      = 'Masukkan nama pengguna';
  static const String validatePassword      = 'Password minimal 6 karakter';
  static const String agreeTermsText        = 'anda menyetujui ';
  static const String agreeTermsText1       = 'ketentuan';
  static const String agreeTermsText2       = 'syarat';
  static const String loginLink             = 'Masuk';
  
  // Forgot Password Page
  static const String forgotPasswordTitle   = 'Lupa Password';
  static const String forgotPasswordSubtitle = 'Silahkan masukkan alamat email anda yang sudah terdaftar';
  static const String resetPasswordButton     = 'Reset Password';
  static const String backToLogin             = 'Kembali ke Login';
  static const String confirmButton           = 'Konfirmasi';
  
  // OTP Page
  static const String otpTitle              = 'Lupa Password';
  static const String otpSubtitle           = 'Masukan kode OTP yang sudah dikirim ke email anda';
  static const String otpCodeLabel          = 'Kode OTP';
  static const String otpNoCodeText         = 'Belum menerima kode OTP? ';
  static const String otpResendButton       = 'Kirim Ulang';
  static const String otpBackButton         = 'Kembali';
  static const String otpEmptyError         = 'Silakan masukkan kode OTP lengkap';
  static const String otpSuccessMessage     = 'Verifikasi OTP berhasil';
  static const String otpResendMessage      = 'Kode OTP baru telah dikirim';
  static const String emailEmptyError       = 'Email tidak boleh kosong';
  static const String otpSendMessage        = 'Kode OTP telah dikirim ke ';
  
  // Change Password Page
  static const String changePasswordTitle   = 'Ubah Password';
  static const String newPasswordHint       = 'Password Baru';
  static const String confirmNewPasswordHint = 'Konfirmasi Password Baru';
  static const String saveButton            = 'SIMPAN';
  static const String passwordEmptyError    = 'Password tidak boleh kosong';
  static const String passwordMismatchError = 'Password tidak sama';
  static const String passwordChangedSuccess = 'Password berhasil diubah, silakan login';
  
  // Terms & Conditions
  static const String termsLinkText         = 'Syarat & Ketentuan';
  
  // Exit Dialog
  static const String exitDialogTitle     = 'Keluar Aplikasi';
  static const String exitDialogMessage   = 'Apakah Anda yakin ingin keluar?';
  static const String exitDialogYes       = 'Ya';
  static const String exitDialogNo        = 'Tidak';
  static const String exitConfirmMessage  = 'Tekan kembali lagi untuk keluar';

  // Attendance screen
  static const String AttendanceTitle          = 'List Absensi';
  static const String CourseTitle              = 'Mata Pelajaran';
  static const String FilterTitle              = 'Filter';
  static const String DownloadTitle            = 'Unduh';
  static const String DateTitle                = 'Tanggal';
  static const String StatusTitle              = 'Status';
  static const String CaptionTitle             = 'Keterangan';
  static const String EmptyState               = 'Tidak ada data absensi\npada tanggal ini.';

  // Attendance scan QR
  static const String AttendanceScanTitle      = 'Scan QR';
  static const String InstructionScan          = 'Pindai Kode QR untuk absensi';

  // Attendance scan Success
  static const String TittleSuccess           = 'Keterangan';
  static const String AttendanceSuccess       = 'Absensi Berhasil';
  static const String CourseSuccess           = 'Mata Pelajaran ';
  static const String DateSuccess             = 'Tanggal ';
  static const String TimeScan                = 'Waktu Scan ';
  static const String StatusScan              = 'Status ';
  

  // Profile screen
  static const String ProfileTitle             = 'Profil';
  static const String EditProfileTitle         = 'Edit Profil';
  static const String EditProfileButton        = 'Edit Profil';

  // SPP screen
  static const String SPPTitle                 = 'SPP';
  static const String SPPMonthTitle            = 'Bulan Pembayaran';
  static const List<String> SPPMonths         = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const String SPPAmount                = 'Rp 500.000';
  static const String SPPStatusLunas           = 'Status: Lunas';
  static const String SPPStatusTerhutang       = 'Status: Terhutang';
  static const String SPPBayar                 = 'Bayar';
  static const String SPPBarcodeTitle          = 'Barcode';
  static const String SPPBarcodeDeadline       = 'Batas Waktu Pembayaran';
  static const String SPPVerifyTitle           = 'Pembayaran Berhasil';

} 