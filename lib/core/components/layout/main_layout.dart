import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/core/components/layout/mobile_drawer.dart';
import 'package:fithub_admin/core/components/layout/web_sidebar.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final GoRouterState state; // Để biết đang ở trang nào

  const MainLayout({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = state.uri.toString();

    return Scaffold(
      // 1. Mobile & Tablet: Hiện AppBar + Drawer
      appBar: Responsive.isMobile(context)
          ? AppBar(
              title: const Text("FitHub Admin"),
              backgroundColor: Colors.white,
              elevation: 1,
            )
          : null,
      drawer: Responsive.isMobile(context)
          ? MobileDrawer(currentRoute: currentRoute)
          : null,

      // 2. Body
      body: Row(
        children: [
          // Web: Hiện Sidebar cố định bên trái
          if (Responsive.isWeb(context)) WebSidebar(currentRoute: currentRoute),

          // Web: Divider dọc
          if (Responsive.isWeb(context))
            const VerticalDivider(width: 1, thickness: 1),

          // Content chính (Thay đổi theo route)
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA), // Màu nền xám nhạt giống mẫu
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
