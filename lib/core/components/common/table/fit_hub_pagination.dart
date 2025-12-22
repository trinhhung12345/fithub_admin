import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FitHubPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const FitHubPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text bên trái
        Text(
          "$currentPage - $totalPages of $totalPages Pages", // Bạn có thể logic lại số item
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),

        // Nút điều hướng bên phải
        Row(
          children: [
            const Text(
              "The page on ",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            // Dropdown page (Giả lập box số trang)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "$currentPage",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const FaIcon(
                    FontAwesomeIcons.caretDown,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Prev Button
            _navButton(
              icon: FontAwesomeIcons.chevronLeft,
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            const SizedBox(width: 8),

            // Next Button
            _navButton(
              icon: FontAwesomeIcons.chevronRight,
              enabled: currentPage < totalPages,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: FaIcon(
          icon,
          size: 14,
          color: enabled ? AppColors.textMain : Colors.grey,
        ),
      ),
    );
  }
}
