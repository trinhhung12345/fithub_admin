import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';
import 'package:fithub_admin/modules/auth/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        // Lấy tên từ cục data API trả về
        userName = user['name'] ?? "Admin";
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clear();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitHub Dashboard"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Text(
              "Hi, $userName  ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              "Chào mừng đến với trang quản trị!",
              style: TextStyle(fontSize: 20, fontFamily: 'Plus Jakarta Sans'),
            ),
          ],
        ),
      ),
    );
  }
}
