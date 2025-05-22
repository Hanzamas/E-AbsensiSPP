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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(userRole, context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(String role, BuildContext context) {
    List<NavItem> items = [];

    switch (role.toLowerCase()) {
      case 'siswa':
        items = [
          NavItem('Home', Icons.home, '/student/home', [role]),
          NavItem('Absensi', Icons.article_outlined, '/student/attendance', [role]),
          NavItem('SPP', Icons.credit_card, '/student/spp', [role]),
          NavItem('Profile', Icons.person, '/student/profile', [role]),
        ];
        break;
      case 'guru':
        items = [
          NavItem('Home', Icons.home, '/teacher/home', [role]),
          NavItem('Absensi', Icons.article_outlined, '/teacher/attendance', [role]),
          NavItem('Akademik', Icons.book, '/teacher/academic', [role]),
          NavItem('Profile', Icons.person, '/teacher/profile', [role]),
        ];
        break;
      case 'admin':
        items = [
          NavItem('Home', Icons.home, '/admin/home', [role]),
          NavItem('Users', Icons.people, '/admin/users', [role]),
          NavItem('Settings', Icons.settings, '/admin/settings', [role]),
          NavItem('Profile', Icons.person, '/admin/profile', [role]),
        ];
        break;
      default:
        items = [
          NavItem('Home', Icons.home, '/home', [role]),
          NavItem('Profile', Icons.person, '/profile', [role]),
        ];
    }

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == currentIndex;

      return Expanded(
        child: GestureDetector(
          onTap: () => _onItemTapped(index, role, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
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

    // Khusus untuk profil, gunakan rute baru dengan format /:role/profile
    if (path.endsWith('/profile')) {
      context.go('/$role/profile');
    } else {
      context.go(path);
    }
  }
} 