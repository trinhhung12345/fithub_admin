import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

class FitHubLabelInput extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  const FitHubLabelInput({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.validator,
    this.isReadOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.obscureText = false,
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

        // 2. Input Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: isReadOnly,
          onTap: onTap,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          style: AppTextStyles.bodyStyle(size: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white, // Nền trắng như thiết kế
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // Viền mặc định (Xám nhạt)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),

            // Viền khi focus (Xanh dương hoặc màu Primary)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.info, width: 1.5),
            ),

            // Viền khi lỗi (Đỏ)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
