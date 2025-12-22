import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    // Logic gọi API Spring Boot sẽ nằm ở đây
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Giả lập chờ API

    isLoading = false;
    notifyListeners();

    print("Email: ${emailController.text}, Pass: ${passwordController.text}");
  }
}
