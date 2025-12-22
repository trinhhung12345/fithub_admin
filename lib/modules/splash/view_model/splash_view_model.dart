import 'package:flutter/material.dart';
import 'package:fithub_admin/modules/auth/view/login_screen.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplashScreen(BuildContext context) async {
    // Giả lập thời gian load (hoặc check token login tại đây)
    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      // Chuyển sang màn hình Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}
