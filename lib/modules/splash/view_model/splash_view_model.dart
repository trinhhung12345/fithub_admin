import 'package:flutter/material.dart';
import 'package:fithub_admin/modules/auth/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplashScreen(BuildContext context) async {
    // ... chờ 2 giây ...
    await Future.delayed(const Duration(seconds: 2));

    String? token = await TokenManager.getToken();
    bool isValid = token != null && TokenManager.isTokenValid(token);

    if (context.mounted) {
      if (isValid) {
        print("DEBUG: Token valid -> Go Dashboard");
        context.go('/dashboard');
      } else {
        print("DEBUG: No token -> Go Login");
        context.go('/login');
      }
    }
  }
}
