import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_main_page.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_edit_page.dart';
import 'package:e_absensi/features/shared/profile/pages/profile_success_page.dart';
import 'package:e_absensi/features/shared/profile/pages/account_edit_page.dart';
import 'package:e_absensi/features/shared/settings/pages/settings_page.dart';
import 'package:e_absensi/core/utils/page_transition_helper.dart';

class SharedRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: '/:role/profile',
      name: 'profile',
      pageBuilder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        return PageTransitionHelper.buildPageWithTransition(
          child: ProfileMainPage(userRole: role),
          type: TransitionType.fade,
          duration: const Duration(milliseconds: 300),
          key: state.pageKey,
        );
      },
    ),
    // GoRoute(
    //   path: '/:role/profile/edit',
    //   name: 'profile-edit',
    //   pageBuilder: (context, state) {
    //     final role = state.pathParameters['role'] ?? 'student';
    //     final isFromLogin = state.extra as bool? ?? false;
    //     return PageTransitionHelper.buildPageWithTransition(
    //       child: ProfileEditPage(isFromLogin: isFromLogin, userRole: role),
    //       type: TransitionType.slideLeft,
    //       duration: const Duration(milliseconds: 300),
    //       key: state.pageKey,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/:role/profile/edit-account',
    //   name: 'profile-edit-account',
    //   pageBuilder: (context, state) {
    //     final role = state.pathParameters['role'] ?? 'student';
    //     return PageTransitionHelper.buildPageWithTransition(
    //       child: AccountEditPage(userRole: role),
    //       type: TransitionType.slideLeft,
    //       duration: const Duration(milliseconds: 300),
    //       key: state.pageKey,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/:role/settings',
    //   name: 'settings',
    //   pageBuilder: (context, state) {
    //     final role = state.pathParameters['role'] ?? 'student';
    //     return PageTransitionHelper.buildPageWithTransition(
    //       child: SettingsPage(userRole: role),
    //       type: TransitionType.slideLeft,
    //       duration: const Duration(milliseconds: 300),
    //       key: state.pageKey,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/:role/profile/success',
    //   name: 'profile-success',
    //   pageBuilder: (context, state) => PageTransitionHelper.buildPageWithTransition(
    //     child: const ProfileSuccessPage(),
    //     type: TransitionType.scaleFade,
    //     duration: const Duration(milliseconds: 400),
    //     curve: Curves.easeOutQuint,
    //     key: state.pageKey,
    //   ),
    // ),
  ];
} 