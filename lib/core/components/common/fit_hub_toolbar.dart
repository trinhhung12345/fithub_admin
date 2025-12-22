import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/configs/app_responsive.dart';

class FitHubToolbar extends StatelessWidget {
  final String hintText;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onExportTap;
  final VoidCallback? onCreateTap;
  final String createLabel;

  const FitHubToolbar({
    super.key,
    this.hintText = "Search for id, name product",
    this.onSearchChanged,
    this.onFilterTap,
    this.onExportTap,
    this.onCreateTap,
    this.createLabel = "New Product",
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra Responsive để bố trí Layout
    final isMobile = Responsive.isMobile(context);

    // Widget Search Bar
    final searchBar = Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ), // Giới hạn chiều rộng trên web
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          // Icon kính lúp bên phải
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
          // Bo tròn kiểu Capsule (như hình)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.info),
          ),
        ),
      ),
    );

    // Các nút bấm (Filter, Export, Create)
    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onFilterTap != null) ...[
          _OutlineActionButton(
            label: "Filter",
            icon: FontAwesomeIcons.filter,
            onTap: onFilterTap!,
          ),
          const SizedBox(width: 12),
        ],

        if (onExportTap != null) ...[
          _OutlineActionButton(
            label: "Export",
            icon: FontAwesomeIcons.download,
            onTap: onExportTap!,
          ),
          const SizedBox(width: 12),
        ],

        if (onCreateTap != null)
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(createLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF0082FF,
              ), // Màu xanh dương sáng trong hình
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
      ],
    );

    // Layout cho Mobile (Dọc) và Web (Ngang)
    if (isMobile) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: searchBar),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: actionButtons,
          ),
        ],
      );
    }

    // Layout cho Web
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: searchBar), // Search bar chiếm phần còn lại
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }
}

// Widget con: Nút bấm viền trắng (Filter, Export)
class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: FaIcon(icon, size: 14, color: AppColors.textMain),
      label: Text(label, style: const TextStyle(color: AppColors.textMain)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
      ),
    );
  }
}
