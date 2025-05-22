/// Helper untuk mendapatkan home route berdasarkan role user
String getHomeRoute(String? role) {
  switch (role) {
    case 'siswa':
      return '/student/home';
    case 'guru':
      return '/teacher/home';
    case 'admin':
      return '/admin/home';
    default:
      return '/login';
  }
} 