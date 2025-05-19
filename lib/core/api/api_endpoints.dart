class ApiEndpoints {
  // Base URL untuk development
  static const String baseUrl = 'https://e-absensi.hanzcode.biz.id';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String userData = '/users';
  
  // Profile endpoints
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  
  // Student endpoints
  static const String getAttendance = '/students/attendance';
  static const String getSPP = '/student/spp';
  static const String paySPP = '/student/spp/pay';
  static const String getSPPHistory = '/student/spp/history';
  static const String getKelas = '/classes';
  static const String getStudentSchedule = '/students/schedule';
  static const String getAttendanceDownload = '/attendance/download';
  
  // Admin endpoints
  static const String getStudents = '/admin/students';
  static const String getAdminAttendance = '/admin/attendance';
  static const String getAttendanceReport = '/admin/attendance/report';
  static const String getSPPReport = '/admin/spp/report';
  static const String addStudent = '/admin/students/add';
  static const String updateStudentAdmin = '/admin/students/update';
  static const String deleteStudent = '/admin/students/delete';
  static const String getAdminStudentDetail = '/admin/students/detail';
  static const String getDashboardStats = '/admin/dashboard/stats';
  static const String getMonthlyReport = '/admin/report/monthly';
  static const String getYearlyReport = '/admin/report/yearly';
} 