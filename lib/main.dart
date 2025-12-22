import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_theme.dart';
import 'package:fithub_admin/modules/auth/view_model/login_view_model.dart';
import 'package:fithub_admin/modules/splash/view/splash_screen.dart'; // Import Splash
import 'package:fithub_admin/modules/splash/view_model/splash_view_model.dart'; // Import Splash VM
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SplashViewModel(),
        ), // Thêm Splash VM
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const FitHubAdminApp(),
    ),
  );
}

class FitHubAdminApp extends StatelessWidget {
  const FitHubAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitHub Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Đổi LoginScreen thành SplashScreen làm màn hình khởi đầu
      home: const SplashScreen(),
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
