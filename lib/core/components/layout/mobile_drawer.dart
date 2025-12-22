import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/menu_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MobileDrawer extends StatelessWidget {
  final String currentRoute;
  const MobileDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: const Text("FitHub Admin"),
            accountEmail: const Text("admin@fithub.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: FaIcon(FontAwesomeIcons.user, color: AppColors.primary),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: MenuConfig.items.map((item) {
                final bool isActive = currentRoute == item.route;
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
                  onTap: () {
                    context.go(item.route); // Chuyển trang
                    Navigator.pop(context); // Đóng Drawer
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
