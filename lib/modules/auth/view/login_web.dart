import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'widgets/login_form.dart'; // Chút nữa mình tạo widget này dùng chung

class LoginWeb extends StatelessWidget {
  const LoginWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cột trái: Chiếm 40-50% màn hình để chứa Form
        const Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: LoginForm(),
          ),
        ),
        // Cột phải: Banner màu xanh (hoặc màu cam #f64400 của bạn)
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.primary, // Sử dụng màu xanh #0082ff bạn đã chọn
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Quản lý Cửa hàng dụng cụ thể thao FitHub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Sau này bạn đặt ảnh Dashboard preview ở đây
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
