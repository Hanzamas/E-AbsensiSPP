import 'package:go_router/go_router.dart';
import 'package:e_absensi/features/teacher/dashboard/pages/teacher_dashboard_page.dart';
import 'package:e_absensi/features/teacher/attendance/pages/teacher_attendance_page.dart'; // Uncomment
import 'package:e_absensi/features/teacher/attendance/pages/attendance_detail_page.dart'; // Add
import 'package:e_absensi/core/utils/page_transition_helper.dart';

class TeacherRoutes {
  static final List<RouteBase> routes = [
    // Teacher Dashboard
    GoRoute(
      path: '/teacher/home',
      name: 'teacher-home',
      pageBuilder: (context, state) => PageTransitionHelper.fadeTransition(
        child: const TeacherDashboardPage(),
        duration: const Duration(milliseconds: 500),
        key: state.pageKey,
      ),
    ),
    
    // Teacher Attendance - Uncomment dan fix
    GoRoute(
      path: '/teacher/attendance',
      name: 'teacher-attendance',
      pageBuilder: (context, state) => PageTransitionHelper.slideRightTransition(
        child: const TeacherAttendancePage(),
        duration: const Duration(milliseconds: 400),
        key: state.pageKey,
      ),
    ),
    
    // Attendance Detail - Add this route
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