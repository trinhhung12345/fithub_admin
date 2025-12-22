import 'package:flutter/material.dart';
import 'package:fithub_admin/data/services/auth_service.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';
import 'package:fithub_admin/modules/dashboard/view/dashboard_screen.dart'; // Import Dashboard
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Để encode json lưu user info
import 'package:go_router/go_router.dart';

class LoginViewModel extends ChangeNotifier {
  AuthService get _authService => AuthService();

  // Đặt giá trị mặc định để test cho nhanh
  final emailController = TextEditingController(
    text: "wearingarmor12345@gmail.com",
  );
  final passwordController = TextEditingController(text: "hung12345");

  bool isLoading = false;
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Kiểm tra accessToken có thực sự tồn tại không
      if (result.accessToken != null) {
        print("DEBUG: Token lấy được: ${result.accessToken}");

        // 1. Lưu Token
        await TokenManager.saveToken(result.accessToken!);

        // 2. Lưu thông tin User (Tên, Email, ID) để hiển thị lên Header
        if (result.userInfo != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_info', jsonEncode(result.userInfo));
        }

        if (context.mounted) {
          // 3. Chuyển sang Dashboard (Xóa hết lịch sử back để không quay lại login dc)
          context.go('/dashboard');
        }
      } else {
        print("DEBUG: Token vẫn null dù API báo 200");
      }
    } catch (e) {
      print("DEBUG: Lỗi: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi đăng nhập: $e")));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
