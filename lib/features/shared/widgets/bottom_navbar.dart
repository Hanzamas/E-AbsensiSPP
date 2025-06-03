import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String siswaRole = 'siswa';
const String guruRole = 'guru';
const String adminRole = 'admin';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  NavItem(this.label, this.icon, this.route);
}

final Map<String, List<NavItem>> navItemsByRole = {
  siswaRole: [
    NavItem('Home', Icons.home, '/student/home'),
    NavItem('Absensi', Icons.article_outlined, '/student/attendance'),
    NavItem('SPP', Icons.credit_card, '/student/spp'),
    NavItem('Profile', Icons.person, '/student/profile'),
  ],
  guruRole: [
    NavItem('Home', Icons.home, '/teacher/home'),
    NavItem('Absensi', Icons.article_outlined, '/teacher/attendance'),
    // ✅ Fix: Remove /teacher/classes karena belum ada
    NavItem('Profile', Icons.person, '/teacher/profile'), // ✅ Change index
  ],
  adminRole: [
    NavItem('Home', Icons.home, '/admin/home'),
    NavItem('Akademik', Icons.school, '/admin/akademik'),
    NavItem('Users', Icons.people, '/admin/users'),
    NavItem('Profil', Icons.person, '/admin/profile'),
  ],
};

int getNavIndex(String role, String path) {
  final items = navItemsByRole[role.toLowerCase()] ?? navItemsByRole[siswaRole]!;
  return items.indexWhere((item) => item.route == path);
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
    final items = navItemsByRole[userRole.toLowerCase()] ?? navItemsByRole[siswaRole]!;
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
            children: List.generate(items.length, (index) {
              final item = items[index];
      final isSelected = index == currentIndex;
      return Expanded(
        child: GestureDetector(
                  onTap: () => _onItemTapped(index, userRole, context),
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
            }),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, String role, BuildContext context) {
    final items = navItemsByRole[role.toLowerCase()] ?? navItemsByRole[siswaRole]!;
    final path = items[index].route;
    
    // ✅ Fix: Handle profile routes properly
    if (path.endsWith('/profile')) {
      // Use role-specific profile route
      context.go('/${role.toLowerCase()}/profile');
    } else {
      context.go(path);
    }
  } 
}