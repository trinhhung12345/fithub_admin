import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

// 1. Định nghĩa Cột
class FitHubColumn {
  final String label;
  final int flex; // Độ rộng tương đối (Web)
  final bool isSortable;

  FitHubColumn({required this.label, this.flex = 1, this.isSortable = false});
}

// 2. Badge Trạng thái (Available/Out of Stock/...)
class FitHubStatusBadge extends StatelessWidget {
  final String label;
  final Color color; // Màu chữ
  final Color backgroundColor; // Màu nền

  const FitHubStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  // Factory constructor cho các trạng thái hay dùng
  factory FitHubStatusBadge.success(String label) => FitHubStatusBadge(
    label: label,
    color: const Color(0xFF22C55E),
    backgroundColor: const Color(0xFFDCFCE7),
  );

  factory FitHubStatusBadge.error(String label) => FitHubStatusBadge(
    label: label,
    color: const Color(0xFFEF4444),
    backgroundColor: const Color(0xFFFEE2E2),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// 3. Action Buttons (View, Edit, Delete)
class FitHubActionButtons extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FitHubActionButtons({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null) _iconBtn(FontAwesomeIcons.eye, onView!),
        if (onEdit != null) _iconBtn(FontAwesomeIcons.penToSquare, onEdit!),
        if (onDelete != null) _iconBtn(FontAwesomeIcons.trashCan, onDelete!),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: FaIcon(icon, size: 16, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30),
    );
  }
}
