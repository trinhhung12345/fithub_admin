import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'login_mobile.dart';
import 'login_web.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: LoginMobile(), // Giao diện 1 cột như hình 2
        web: LoginWeb(), // Giao diện 2 cột như hình 1
      ),
    );
  }
}
