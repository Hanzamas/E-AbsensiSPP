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
  
  
  // Register Page
  static const String registerTitle         = 'Daftar';
  static const String registerSubtitle      = 'Silahkan masuk terlebih dahulu';
  static const String registerButton        = 'DAFTAR';
  static const String haveAccount           = 'Sudah punya akun? ';
  static const String usernameHint          = 'Nama';
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
  static const String termsAndConditionsTitle = 'Syarat & Ketentuan';
  static const String understandButton      = 'Saya Mengerti';
  static const String termsAndConditionsContent = '''
    1. Anda harus menjaga kerahasiaan akun Anda, termasuk email dan password.
    2. Semua aktivitas yang dilakukan menggunakan akun Anda adalah tanggung jawab Anda sepenuhnya.
    3. Data absensi harus akurat dan tidak dimanipulasi.
    4. Data absensi disimpan secara aman, tetapi pengembang tidak bertanggung jawab atas kehilangan data karena kesalahan pengguna.
    5. Jangan menyalahgunakan aplikasi ini untuk tujuan komersial atau ilegal tanpa izin tertulis dari pengembang.
    6. Aplikasi dan semua komponennya dilindungi oleh undang-undang hak cipta; Anda tidak boleh mendistribusikan ulang atau memodifikasi tanpa izin.
    7. Pengguna tidak diperbolehkan untuk melakukan reverse engineering, decompile, atau memodifikasi kode sumber aplikasi.
    8. Pengembang berhak untuk menghentikan, membatasi, atau memodifikasi layanan kapan saja tanpa pemberitahuan sebelumnya.
    9. Pengguna setuju untuk menerima pembaruan aplikasi otomatis yang mungkin berisi perbaikan, fitur baru, atau perubahan kebijakan.
    10. Pengguna harus memasukkan data yang valid dan bertanggung jawab atas keakuratan informasi yang diberikan.
    11. Fitur backup dan restore disediakan, tetapi pengembang tidak menjamin 100% keberhasilan dalam pemulihan data.
    12. Setiap bentuk pelanggaran (penipuan, peretasan, spam) akan mengakibatkan penangguhan akun permanen.
    13. Pengguna bertanggung jawab atas perangkat mereka—jika hilang atau dicuri, segera laporkan ke admin sekolah.
    14. Pengembang tidak akan pernah meminta informasi sensitif di luar mekanisme aplikasi resmi.
    15. Untuk keluhan atau pertanyaan, hubungi tim dukungan: support@e-absensispp.com.

    Dengan melanjutkan, Anda setuju dengan semua ketentuan di atas dan bertanggung jawab atas penggunaan aplikasi ini.
    ''';
    
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

  // Profile screen
  static const String ProfileTitle             = 'Profil';
  static const String EditProfileTitle         = 'Edit Profil';
  static const String EditProfileButton        = 'Edit Profil';

  // SPP screen
  static const String SPPTitle                 = 'SPP';

} 