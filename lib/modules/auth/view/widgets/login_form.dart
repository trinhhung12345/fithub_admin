import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/components/common/fit_hub_button.dart';
import 'package:fithub_admin/core/components/common/fit_hub_text_field.dart';
import 'package:fithub_admin/modules/auth/view_model/login_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Provider để lắng nghe ViewModel
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Logo (Thay bằng ảnh logo của bạn sau này)
              const Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.dumbbell,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "FitHub Admin",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Title & Subtitle
              const Text(
                "Đăng nhập",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Chào mừng bạn trở lại! Vui lòng đăng nhập để tiếp tục.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 32),

              // 3. Email Field
              FitHubTextField(
                label: "Email",
                hintText: "Nhập email của bạn",
                controller: viewModel.emailController,
              ),
              const SizedBox(height: 20),

              // 4. Password Field
              FitHubTextField(
                label: "Mật khẩu",
                hintText: "••••••••",
                controller: viewModel.passwordController,
                isPassword: !viewModel.isPasswordVisible,
                suffixIcon: IconButton(
                  icon: FaIcon(
                    viewModel.isPasswordVisible
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: viewModel.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 16),

              // 5. Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: viewModel.rememberMe,
                        onChanged: viewModel.toggleRememberMe,
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        "Ghi nhớ đăng nhập",
                        style: TextStyle(fontFamily: 'Manrope'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Quên mật khẩu?",
                      style: TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 6. Sign In Button
              FitHubButton(
                label: "Đăng nhập",
                isLoading: viewModel.isLoading,
                onPressed: () => viewModel.login(context),
              ),

              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  children: [
                    const Text(
                      "Do not have an account? ",
                      style: TextStyle(fontFamily: 'Manrope'),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Contact Admin",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
