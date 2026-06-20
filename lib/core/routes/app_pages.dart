import 'package:get/get.dart';

import '../../presentation/auth/auth_binding.dart';
import '../../presentation/auth/auth_view.dart';
import '../../presentation/dashboard/dashboard_binding.dart';
import '../../presentation/dashboard/dashboard_view.dart';
import '../../presentation/focus/focus_binding.dart';
import '../../presentation/focus/focus_view.dart';
import '../../presentation/splash/splash_binding.dart';
import '../../presentation/splash/splash_view.dart';
import '../../presentation/tasks/task_binding.dart';
import '../../presentation/tasks/task_board_view.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/deep_link_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware(), DeepLinkMiddleware()],
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 360),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TaskBoardView(),
      binding: TaskBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 360),
    ),
    GetPage(
      name: AppRoutes.focus,
      page: () => const FocusView(),
      binding: FocusBinding(),
      middlewares: [AuthMiddleware(), DeepLinkMiddleware()],
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 360),
    ),
  ];
}
