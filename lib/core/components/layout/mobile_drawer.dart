import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/menu_config.dart';

class MobileDrawer extends StatefulWidget {
  final String currentRoute;
  const MobileDrawer({super.key, required this.currentRoute});

  @override
  State<MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<MobileDrawer> {
  String _name = "FitHub Admin";
  String _email = "admin@fithub.com";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load thông tin user từ Local Storage (đã lưu lúc Login)
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        _name = user['name'] ?? "Admin";
        _email = user['email'] ?? "admin@fithub.com";
      });
    }
  }

  void _navigateToProfile() {
    Navigator.pop(context); // 1. Đóng Drawer trước
    context.go('/profile'); // 2. Chuyển sang trang Profile
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // --- PHẦN HEADER PROFILE (Có thể bấm được) ---
          InkWell(
            onTap: _navigateToProfile,
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: Text(
                _name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(_email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              // Mũi tên nhỏ để gợi ý là bấm được
              onDetailsPressed: _navigateToProfile,
              arrowColor: Colors.white,
            ),
          ),

          // --- PHẦN MENU ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: MenuConfig.items.map((item) {
                final bool isActive = widget.currentRoute.startsWith(
                  item.route,
                );
                return ListTile(
                  leading: FaIcon(
                    item.icon,
                    size: 20,
                    color: isActive ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isActive ? AppColors.primary : Colors.black87,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isActive,
                  selectedTileColor: AppColors.primary.withOpacity(0.05),
                  onTap: () {
                    context.go(item.route);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
