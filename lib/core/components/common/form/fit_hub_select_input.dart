import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

class FitHubSelectInput<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T)
  itemLabelBuilder; // Hàm để lấy tên hiển thị từ object T
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const FitHubSelectInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.itemLabelBuilder,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label
        Text(
          label,
          style: AppTextStyles.bodyStyle(
            weight: FontWeight.bold,
            size: 14,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),

        // 2. Dropdown Field
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: AppTextStyles.bodyStyle(size: 15),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          icon: const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 14,
            color: Colors.grey,
          ),
          isExpanded: true, // Để text dài không bị lỗi overflow
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // Viền y hệt FitHubLabelInput
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.info, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          // Cấu hình menu xổ xuống
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
