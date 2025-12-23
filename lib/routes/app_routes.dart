import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fithub_admin/modules/auth/view/login_screen.dart';
import 'package:fithub_admin/modules/dashboard/view/dashboard_screen.dart';
import 'package:fithub_admin/modules/splash/view/splash_screen.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';
import 'package:fithub_admin/core/components/layout/main_layout.dart';
import 'package:fithub_admin/modules/management/view/product_screen.dart';
import 'package:fithub_admin/modules/management/view/product_form_screen.dart';
import 'package:fithub_admin/modules/management/view/category_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Các trang không có Sidebar (Splash, Login)
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // SHELL ROUTE: Các trang CÓ Sidebar/Drawer
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductScreen(),
            routes: [
              // Route: Thêm mới sản phẩm
              GoRoute(
                path: 'form',
                builder: (context, state) => const ProductFormScreen(),
              ),
              // Route: Sửa sản phẩm (có ID)
              GoRoute(
                path: 'form/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return ProductFormScreen(productId: id);
                },
              ),
            ],
          ),

          // --- CATEGORY ROUTE (THÊM MỚI Ở ĐÂY) ---
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoryScreen(),
          ),

          // GoRoute(
          //   path: '/categories',
          //   builder: (context, state) => const CategoryScreen(),
          // ),
          // GoRoute(
          //   path: '/orders',
          //   builder: (context, state) => const OrderScreen(),
          // ),
          // GoRoute(
          //   path: '/users',
          //   builder: (context, state) => const UserScreen(),
          // ),
        ],
      ),
    ],
  );
}
