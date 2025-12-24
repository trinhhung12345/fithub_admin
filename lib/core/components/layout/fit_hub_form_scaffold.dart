import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';

class FitHubFormScaffold extends StatelessWidget {
  // Header Info
  final String title;
  final List<BreadcrumbItem> breadcrumbs;

  // Content
  final Widget
  mainInfo; // Phần bên trái (Web) hoặc bên trên (Mobile) - Chứa Input
  final Widget
  sideInfo; // Phần bên phải (Web) hoặc bên dưới (Mobile) - Chứa ImagePicker

  // Actions
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;
  final bool isLoading;

  const FitHubFormScaffold({
    super.key,
    required this.title,
    required this.breadcrumbs,
    required this.mainInfo,
    required this.sideInfo,
    this.onSave,
    this.onDiscard,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Màu nền xám nhạt
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Title + Breadcrumb)
            _buildHeader(),
            const SizedBox(height: 24),

            // 2. Body (Responsive Layout)
            Responsive(mobile: _buildMobileLayout(), web: _buildWebLayout()),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingStyle(size: 28)),
        const SizedBox(height: 8),
        FitHubBreadcrumb(items: breadcrumbs),
      ],
    );
  }

  // --- WEB LAYOUT (2 Cột) ---
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột trái: Form thông tin chính (Chiếm 7 phần)
        Expanded(
          flex: 7,
          child: _buildCardContainer(
            title: "General Information", // Hoặc tham số hóa nếu cần
            child: mainInfo,
          ),
        ),
        const SizedBox(width: 24),

        // Cột phải: Ảnh + Nút bấm (Chiếm 3 phần)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildCardContainer(child: sideInfo),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  // --- MOBILE LAYOUT (1 Cột dọc) ---
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCardContainer(title: "General Information", child: mainInfo),
        const SizedBox(height: 24),
        _buildCardContainer(child: sideInfo),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  // --- HELPER: KHUNG THẺ TRẮNG (Card) ---
  Widget _buildCardContainer({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: AppTextStyles.headingStyle(size: 20)),
            const SizedBox(height: 4),
            Text(
              "Fill in the details below",
              style: AppTextStyles.bodyStyle(
                color: AppColors.textSecondary,
                size: 14,
              ),
            ),
            const SizedBox(height: 24),
          ],
          child,
        ],
      ),
    );
  }

  // --- HELPER: ACTION BUTTONS (Save / Discard) ---
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Discard Button
        Expanded(
          child: OutlinedButton(
            onPressed: onDiscard,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.info),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              "Discard",
              style: TextStyle(
                color: AppColors.info,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Save Button
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.info,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
