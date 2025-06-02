import 'package:go_router/go_router.dart';
import 'package:e_absensi/features/teacher/dashboard/pages/teacher_dashboard_page.dart';
import 'package:e_absensi/features/teacher/attendance/pages/teacher_attendance_page.dart';
import 'package:e_absensi/features/teacher/attendance/pages/attendance_detail_page.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_main_page.dart'; // ✅ Add import
import 'package:e_absensi/core/utils/page_transition_helper.dart';

class TeacherRoutes {
  static final List<RouteBase> routes = [
    // Teacher Dashboard
    GoRoute(
      path: '/teacher/home', // ✅ Change path to match existing navigation
      name: 'teacher-home',
      pageBuilder: (context, state) => PageTransitionHelper.fadeTransition(
        child: const TeacherDashboardPage(),
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    
    // Teacher Attendance
    GoRoute(
      path: '/teacher/attendance',
      name: 'teacher-attendance',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const TeacherAttendancePage(),
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    
    // ✅ ADD: Teacher Profile Route
    GoRoute(
      path: '/teacher/profile',
      name: 'teacher-profile',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const ProfileMainPage(userRole: 'guru'),
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    
    // Attendance Detail
    GoRoute(
      path: '/teacher/attendance/detail/:attendanceId',
      name: 'teacher-attendance-detail', 
      pageBuilder: (context, state) {
        final attendanceId = state.pathParameters['attendanceId']!;
        return PageTransitionHelper.slideRightTransition(
          child: AttendanceDetailPage(attendanceId: attendanceId),
          duration: const Duration(milliseconds: 400),
          key: state.pageKey,
        );
      },
    ),
  ];
}