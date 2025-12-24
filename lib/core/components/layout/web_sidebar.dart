import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/menu_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class WebSidebar extends StatelessWidget {
  final String currentRoute;
  const WebSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // 1. Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.dumbbell,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "FitHub",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),

          // 2. Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: MenuConfig.items.map((item) {
                final bool isActive = currentRoute == item.route;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: isActive
                      ? BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        )
                      : null,
                  child: ListTile(
                    leading: FaIcon(
                      item.icon,
                      size: 20,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => context.go(item.route),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. User Profile Bottom (Optional giống mẫu)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => context.go('/profile'),
              borderRadius: BorderRadius.circular(8),
              child: const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.person, color: Color(0xFF1E88E5)),
                ),
                title: Text(
                  "Trinh Van Hung",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Admin", style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
