class ApiEndpoints {
  // Base URL untuk development
  static const String baseUrl = 'https://e-absensi.hanzcode.biz.id';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  
  // Users
  static const String usersMy = '/users/my';
  static const String usersUpdate = '/users/update';
  static const String usersUpdatePassword = '/users/update-password';

  // File
  static const String filesUpload = '/files/upload';
  static const String filesUpdate = '/files/update';
  static const String filesDelete = '/files/delete';
  static const String uploads = '/uploads';
  
  // Siswa
  static const String getStudentProfile = '/profile/student';
  static const String updateStudent = '/students/update';
  static const String getStudentAttendance = '/studens/attendance/my';
  static const String getStudentDownloadAttendance = '/students/download-attendance';
  static const String scanStudentAttendance = '/studens/attendance/scan';
  static const String getStudentSchedule = '/students/schedule';
  static const String getKelas = '/classes';
  static const String getAttendanceDetail = '/studens/attendance/my';
  
  // Guru
  static const String getTeacherProfile = '/profile/teacher';
  static const String updateTeacher = '/teachers/update';
  // Admin

  

} 