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
  NavItem('Absensi', Icons.checklist, '/attendance', ['siswa', 'guru', 'admin']),
  NavItem('SPP', Icons.credit_card, '/spp', ['siswa']),
  NavItem('Profile', Icons.person, '/profile', ['siswa', 'guru', 'admin']),
];

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

  List<NavItem> get navItems {
    final role = userRole.toLowerCase();
    // Ambil home yang sesuai role
    final home = allNavItems.firstWhere((item) => item.label == 'Home' && item.roles.contains(role));
    // Ambil item lain yang role-nya mengandung role
    final others = allNavItems.where((item) => item.label != 'Home' && item.roles.contains(role)).toList();
    return [home, ...others];
  }

  @override
  Widget build(BuildContext context) {
    final items = navItems;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < items.length) {
          context.go(items[index].route);
        }
      },
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
      items: items.map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label)).toList(),
      type: BottomNavigationBarType.fixed,
    );
  }
}

int getNavIndex(String userRole, String currentRoute) {
  final role = userRole.toLowerCase();
  final home = allNavItems.firstWhere((item) => item.label == 'Home' && item.roles.contains(role));
  final items = allNavItems.where((item) => item.roles.contains(role) && item.label != 'Home').toList();
  final navItems = [home, ...items];
  final idx = navItems.indexWhere((item) => item.route == currentRoute);
  return idx == -1 ? 0 : idx;
} 