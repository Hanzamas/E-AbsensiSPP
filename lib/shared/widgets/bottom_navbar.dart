import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<String> roles; // ['siswa', 'guru', 'admin']
  NavItem(this.label, this.icon, this.route, this.roles);
}

final List<NavItem> allNavItems = [
  NavItem('Home', Icons.home, '/student/home', ['siswa']),
  NavItem('Home', Icons.home, '/teacher/home', ['guru']),
  NavItem('Home', Icons.home, '/admin/home', ['admin']),
  NavItem('Absensi', Icons.article_outlined, '/student/attendance', ['siswa']),
  NavItem('Absensi', Icons.article_outlined, '/teacher/attendance', ['guru']),
  NavItem('SPP', Icons.credit_card, '/student/spp', ['siswa']), 
  NavItem('Profile', Icons.person, '/student/profile', ['siswa']),
  NavItem('Profile', Icons.person, '/teacher/profile', ['guru']),
  NavItem('Profile', Icons.person, '/admin/profile', ['admin']),
];

// Function untuk mendapatkan indeks navigasi
int getNavIndex(String role, String path) {
  final studentPaths = {
    '/student/home': 0,
    '/student/attendance': 1,
    '/student/spp': 2,
    '/student/profile': 3,
  };

  final teacherPaths = {
    '/teacher/home': 0,
    '/teacher/attendance': 1,
    '/teacher/academic': 2,
    '/teacher/profile': 3,
  };

  final adminPaths = {
    '/admin/home': 0,
    '/admin/users': 1,
    '/admin/settings': 2,
    '/admin/profile': 3,
  };

  switch (role.toLowerCase()) {
    case 'siswa':
      return studentPaths[path] ?? 0;
    case 'guru':
      return teacherPaths[path] ?? 0;
    case 'admin':
      return adminPaths[path] ?? 0;
    default:
      return 0;
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String userRole;
  final BuildContext context;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.userRole,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(index, userRole, context),
      items: _getNavItems(userRole),
    );
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    switch (role.toLowerCase()) {
      case 'siswa':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Absensi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'SPP',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'guru':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Absensi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Akademik',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'admin':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      default:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }

  void _onItemTapped(int index, String role, BuildContext context) {
    if (index == currentIndex) return;

    String path = '/';
    switch (role.toLowerCase()) {
      case 'siswa':
        switch (index) {
          case 0:
            path = '/student/home';
            break;
          case 1:
            path = '/student/attendance';
            break;
          case 2:
            path = '/student/spp';
            break;
          case 3:
            path = '/student/profile';
            break;
        }
        break;
      case 'guru':
        switch (index) {
          case 0:
            path = '/teacher/home';
            break;
          case 1:
            path = '/teacher/attendance';
            break;
          case 2:
            path = '/teacher/academic';
            break;
          case 3:
            path = '/teacher/profile';
            break;
        }
        break;
      case 'admin':
        switch (index) {
          case 0:
            path = '/admin/home';
            break;
          case 1:
            path = '/admin/users';
            break;
          case 2:
            path = '/admin/settings';
            break;
          case 3:
            path = '/admin/profile';
            break;
        }
        break;
    }

    context.go(path);
  }
} 