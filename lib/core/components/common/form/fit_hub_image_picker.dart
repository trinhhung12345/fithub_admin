import 'dart:io';
import 'package:dotted_border/dotted_border.dart'; // Import thư viện nét đứt
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';

class FitHubImagePicker extends StatelessWidget {
  final String label;
  final List<dynamic> images; // List chứa ảnh (String URL hoặc File)
  final Function(int index) onImageTap; // Callback khi bấm vào ô ảnh

  const FitHubImagePicker({
    super.key,
    this.label = "Image Product",
    required this.images,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề
        Text(
          label,
          style: AppTextStyles.bodyStyle(
            weight: FontWeight.bold,
            size: 16, // To hơn label input chút
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),

        // 2. Note (Màu xanh dương giống thiết kế)
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyStyle(
              size: 13,
              color: AppColors.textSecondary,
            ),
            children: const [
              TextSpan(
                text: "Note : ",
                style: TextStyle(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: "Format photos SVG, PNG, or JPG (Max size 4mb)"),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Danh sách ô ảnh (4 ô)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            // Lấy ảnh tại index (nếu có)
            final dynamic image = (index < images.length)
                ? images[index]
                : null;

            return Expanded(
              child: Padding(
                // Tạo khoảng cách giữa các ô, trừ ô cuối
                padding: EdgeInsets.only(right: index == 3 ? 0 : 12.0),
                child: _buildImageSlot(index, image),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildImageSlot(int index, dynamic image) {
    // Kích thước ô vuông (Aspect Ratio 1:1)
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () => onImageTap(index),
        child: image != null
            ? _buildFilledSlot(image) // Nếu có ảnh
            : _buildEmptySlot(index), // Nếu chưa có ảnh (Nét đứt)
      ),
    );
  }

  // Trạng thái đã có ảnh (Hiển thị ảnh + nền xám)
  Widget _buildFilledSlot(dynamic image) {
    ImageProvider? imgProvider;

    if (image is String) {
      imgProvider = NetworkImage(image); // Web blob url hoặc http url
    } else if (image is File) {
      imgProvider = FileImage(image); // Mobile File
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        image: imgProvider != null
            ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
            : null,
      ),
      // ...
    );
  }

  // Trạng thái trống (Nét đứt màu xanh)
  Widget _buildEmptySlot(int index) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: EdgeInsets.zero,
      color: AppColors.info, // Màu nét đứt (Xanh dương)
      strokeWidth: 1,
      dashPattern: const [6, 3], // Độ dài nét đứt
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.05), // Nền xanh siêu nhạt
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.image,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                "Photo ${index + 1}",
                style: const TextStyle(
                  color: AppColors.info,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
