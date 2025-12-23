import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart'; // check kIsWeb
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:image_picker/image_picker.dart'; // Import để check XFile

class FitHubImagePicker extends StatelessWidget {
  final String label;
  final List<dynamic>
  images; // List chứa: String (URL), File (Mobile), hoặc XFile
  final VoidCallback onAddTap; // Hàm gọi mở thư viện ảnh
  final Function(int index) onRemoveTap; // Hàm xóa ảnh

  const FitHubImagePicker({
    super.key,
    this.label = "Image Product",
    required this.images,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyStyle(weight: FontWeight.bold, size: 16),
            ),
            Text(
              "${images.length} images selected",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. Note
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
              TextSpan(
                text: "Format photos SVG, PNG, JPG (Max 4mb). Click + to add.",
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Grid ảnh (Wrap)
        Wrap(
          spacing: 12, // Khoảng cách ngang
          runSpacing: 12, // Khoảng cách dọc
          children: [
            // A. Danh sách ảnh đã chọn
            ...List.generate(images.length, (index) {
              return _buildImageItem(index, images[index]);
            }),

            // B. Nút Add (Luôn nằm cuối)
            _buildAddButton(),
          ],
        ),
      ],
    );
  }

  // Widget hiển thị 1 ảnh + Nút xóa
  Widget _buildImageItem(int index, dynamic image) {
    ImageProvider? imgProvider;

    // Xử lý hiển thị đa nền tảng
    if (image is String) {
      imgProvider = NetworkImage(image); // URL từ server
    } else if (image is XFile) {
      // XFile từ image_picker
      if (kIsWeb) {
        imgProvider = NetworkImage(image.path); // Web dùng path (blob)
      } else {
        imgProvider = FileImage(File(image.path)); // Mobile dùng File
      }
    } else if (image is File) {
      imgProvider = FileImage(image);
    }

    return Stack(
      children: [
        // Ảnh nền
        Container(
          width: 100, // Kích thước cố định cho đẹp
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            image: imgProvider != null
                ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
                : null,
          ),
        ),

        // Nút Xóa (Góc trên phải)
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemoveTap(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Nút Thêm (Nét đứt)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: EdgeInsets.zero,
        color: AppColors.info,
        strokeWidth: 1,
        dashPattern: const [6, 3],
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: AppColors.info,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
