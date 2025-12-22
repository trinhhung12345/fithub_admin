import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

class BreadcrumbItem {
  final String title;
  final String? route; // Nếu null thì không click được (thường là item cuối)

  BreadcrumbItem({required this.title, this.route});
}

class FitHubBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const FitHubBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal, // Cho phép cuộn ngang trên mobile nếu quá dài
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Row(
            children: [
              // 1. Text Item
              InkWell(
                onTap: (item.route != null && !isLast)
                    ? () => context.go(item.route!)
                    : null,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  child: Text(
                    item.title,
                    style: isLast
                        ? AppTextStyles.bodyStyle(
                            color: AppColors
                                .info, // Màu xanh dương cho item cuối (theo thiết kế)
                            weight: FontWeight.bold,
                            size: 14,
                          )
                        : AppTextStyles.bodyStyle(
                            color:
                                AppColors.textSecondary, // Màu xám cho item cha
                            weight: FontWeight.w500,
                            size: 14,
                          ),
                  ),
                ),
              ),

              // 2. Separator Icon (Nếu không phải item cuối)
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
