import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fithub_admin/modules/auth/view/login_screen.dart';
import 'package:fithub_admin/modules/dashboard/view/dashboard_screen.dart';
import 'package:fithub_admin/modules/splash/view/splash_screen.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';

class AppRouter {
  // Cấu hình router
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Mặc định vào Splash
    debugLogDiagnostics: true, // Log debug khi chuyển trang
    // Định nghĩa các đường dẫn
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 3. Dashboard Screen
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],

    // Redirect Logic: (Tùy chọn nâng cao)
    // Tại đây bạn có thể kiểm tra nếu chưa có Token thì đá về Login
    // Nhưng hiện tại ta đang xử lý logic này ở Splash nên tạm thời để null
    redirect: (context, state) async {
      // Logic bảo vệ route sẽ nằm ở đây sau này
      return null;
    },
  );
}
