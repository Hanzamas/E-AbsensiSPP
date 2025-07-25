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
  static const String getStudentAttendance = '/students/attendance/my';
  static const String getStudentDownloadAttendance =
      '/students/download-attendance';
  static const String scanStudentAttendance = '/students/attendance/scan';
  static const String getStudentSchedule = '/students/schedule';
  static const String getKelas = '/classes';
  static const String getAttendanceDetail = '/students/attendance/my';
  static const String getStudentSppBill =
      '/students/spp-bill'; // Tagihan yang belum dibayar
  static const String payStudentSpp =
      '/students/pay-spp'; // Create QRIS payment
  static const String getStudentPaymentHistory =
      '/students/payment-history'; // Histori pembayaran

  // Guru
  static const String getTeacherProfile = '/profile/teacher';
  static const String updateTeacher = '/teachers/update';
  static const String getTeacherSchedule = '/teacher/teaching/my';
  static const String createLearningSession =
      '/teacher/learning-session/assign';
  static const String getTeacherAttendance = '/teachers/attendance';
  static const String getTeacherAttendanceById =
      '/teacher/attendance'; // Will append /:id
  static const String updateTeacherAttendance =
      '/teachers/attendance/update'; // Will append /:id

  // Admin academic
  static const String getClasses = '/admin/classes';
  static const String createClass = '/admin/classes/create';
  static const String updateClass = '/admin/classes/update'; // Will append /:id
  static const String deleteClass = '/admin/classes/delete';
  // admin users students
  static const String getStudents = '/admin/students';
  static const String deleteStudent =
      '/admin/students/delete'; // Will append /:id
  static const String createStudentadmin = '/admin/students/create';
  static const String updateStudentadmin =
      '/admin/students/update'; // Will append /:id
  // admin users teachers
  static const String getTeachersAdmin = '/admin/teachers';
  static const String createTeacherAdmin = '/admin/teachers/create';
  static const String updateTeacherAdmin = '/admin/teachers/update';
  static const String deleteTeacherAdmin = '/admin/teachers/delete';
  static const String getFormatDownloadTeacher =
      '/admin/teachers/template-excel';
  static const String importTeacher = '/admin/teachers/import-excel';
  // admin users academic year
  static const String createAcademicYear = '/admin/academic-year/create';
  static const String getAcademicYears = '/admin/academic-year';
  static const String updateAcademicYear = '/admin/academic-year/update';
  static const String deleteAcademicYear = '/admin/academic-year/delete';

  // admin users subjects
  static const getSubjects = '/admin/subjects';
  static const createSubject = '/admin/subjects/create';
  static const updateSubject = '/admin/subjects/update';
  static const deleteSubject = '/admin/subjects/delete';

  // admin users teaching
  static const getTeachings = '/admin/teaching';
  static const createTeaching = '/admin/teaching/create';
  static const updateTeaching = '/admin/teaching/update'; // Will append /:id
  static const deleteTeaching = '/admin/teaching/delete'; // Will append /:id

   static const String downloadSppReport = '/admin/spp/report/download';
   static const String downloadAttendanceReport = '/admin/attendance/report/download';

    static const String getAllSppReports = '/admin/spp/report';
     static const String getAllAttendanceReports = '/admin/attendance/report';
}
