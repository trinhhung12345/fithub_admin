import 'package:flutter/material.dart';
import 'widgets/login_form.dart';

class LoginMobile extends StatelessWidget {
  const LoginMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: LoginForm(), // Dùng lại đúng cái form đó
      ),
    );
  }
}
