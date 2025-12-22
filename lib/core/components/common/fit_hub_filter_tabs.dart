import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

class FitHubFilterTabs extends StatelessWidget {
  final List<String>
  tabs; // Danh sách tên tab: ["Sneakers (50)", "Jacket (26)"]
  final int selectedIndex; // Tab nào đang được chọn
  final Function(int) onTabSelected; // Hàm callback khi bấm vào

  const FitHubFilterTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        4,
      ), // Padding nhỏ giữa viền ngoài và nút bên trong
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(50), // Bo tròn mạnh
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Nếu màn hình quá nhỏ (Mobile dọc) mà nhiều tab -> Cho phép cuộn ngang
          // Nếu màn hình rộng (Web/Tablet) -> Chia đều (Expanded)

          bool useScroll = constraints.maxWidth < 600 && tabs.length > 3;

          if (useScroll) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildTabItem(entry.key, entry.value),
                  );
                }).toList(),
              ),
            );
          }

          // Mặc định Web: Chia đều không gian (Expanded)
          return Row(
            children: tabs.asMap().entries.map((entry) {
              return Expanded(child: _buildTabItem(entry.key, entry.value));
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final bool isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Màu nền khi chọn: Xanh nhạt. Không chọn: Trong suốt
          color: isSelected
              ? const Color(0xFFE3F2FD)
              : Colors.transparent, // Hoặc AppColors.info.withOpacity(0.1)
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyStyle(
            // Màu chữ khi chọn: Xanh đậm. Không chọn: Xám
            color: isSelected
                ? const Color(0xFF0082FF)
                : AppColors.textSecondary,
            weight: isSelected ? FontWeight.bold : FontWeight.w600,
            size: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
