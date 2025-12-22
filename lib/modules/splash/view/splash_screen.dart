import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/modules/splash/view_model/splash_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Tạo hiệu ứng phóng to nhẹ cho logo
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();

    // Gọi logic chuyển màn từ ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().initSplashScreen(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Màu cam #f64400
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị logo SVG
              SvgPicture.asset(
                'assets/icons/Logo.svg',
                width: 300, // Điều chỉnh kích thước cho phù hợp
                // Đổi logo sang màu trắng trên nền cam
              ),
              const SizedBox(height: 24),
              // Optional: Hiển thị thêm loading indicator kiểu trắng cho hợp nền cam
              const SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
