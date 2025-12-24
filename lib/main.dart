import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_theme.dart';
import 'package:fithub_admin/modules/auth/view_model/login_view_model.dart';
import 'package:fithub_admin/modules/splash/view_model/splash_view_model.dart';
import 'package:fithub_admin/routes/app_routes.dart'; // Import router
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:fithub_admin/modules/management/view_model/product_view_model.dart';
import 'package:fithub_admin/modules/management/view_model/category_view_model.dart';
import 'package:fithub_admin/modules/management/view_model/order_view_model.dart';
import 'package:fithub_admin/modules/dashboard/view_model/dashboard_view_model.dart';
import 'package:fithub_admin/modules/profile/view_model/profile_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const FitHubAdminApp(),
    ),
  );
}

class FitHubAdminApp extends StatelessWidget {
  const FitHubAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ĐỔI THÀNH MaterialApp.router
    return MaterialApp.router(
      title: 'FitHub Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Cấu hình Router
      routerConfig: AppRouter.router,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
