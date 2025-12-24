import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';
import 'package:fithub_admin/modules/profile/view_model/profile_view_model.dart';
import 'package:fithub_admin/modules/profile/view/widgets/change_password_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers cho Form
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // Readonly
  final _codeCtrl = TextEditingController(); // Readonly
  final _birthdayCtrl = TextEditingController(); // Chọn qua DatePicker

  DateTime? _selectedDate; // Lưu ngày sinh thực tế để gửi API

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final vm = context.read<ProfileViewModel>();
    await vm.getProfile();

    // Sau khi load xong, điền vào controller
    if (vm.user != null) {
      _nameCtrl.text = vm.user!.name;
      _phoneCtrl.text = vm.user!.phone;
      _addressCtrl.text = vm.user!.address;
      _emailCtrl.text = vm.user!.email;
      _codeCtrl.text = vm.user!.code;

      if (vm.user!.birthday != null) {
        _selectedDate = vm.user!.birthday;
        _birthdayCtrl.text = DateFormat("dd/MM/yyyy").format(_selectedDate!);
      }
    }
  }

  // Hàm chọn ngày sinh
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayCtrl.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select birthday")));
      return;
    }

    final success = await context.read<ProfileViewModel>().updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      birthday: _selectedDate!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await TokenManager.clear();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.user;
    final isMobile = Responsive.isMobile(context); // Check mobile

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Profile", style: AppTextStyles.headingStyle(size: 28)),
            const SizedBox(height: 8),
            FitHubBreadcrumb(
              items: [
                BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
                BreadcrumbItem(title: "Profile", route: null),
              ],
            ),
            const SizedBox(height: 24),

            if (viewModel.isLoading && user == null) // Loading lần đầu
              const Center(child: CircularProgressIndicator())
            else if (user == null)
              const Center(child: Text("Could not load profile"))
            else
              // SỬA: Dùng Column trên mobile, Row trên web cho bố cục chính
              isMobile
                  ? Column(
                      children: [
                        _buildProfileCard(user),
                        const SizedBox(height: 24),
                        _buildDetailsCard(viewModel.isLoading, isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildProfileCard(user)),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 7,
                          child: _buildDetailsCard(
                            viewModel.isLoading,
                            isMobile,
                          ),
                        ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  // ... _buildProfileCard Giữ nguyên như cũ ...
  Widget _buildProfileCard(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : "A",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FitHubStatusBadge(
            label: user.roleName,
            color: AppColors.info,
            backgroundColor: AppColors.info.withOpacity(0.1),
          ),
          const SizedBox(height: 32),

          // 1. Change Password Button (MỚI)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const ChangePasswordDialog(),
                );
              },
              icon: const Icon(Icons.lock_reset, size: 18),
              label: const Text("Change Password"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Log Out Button (CŨ)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Log Out"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Card Form (Đã cập nhật)
  Widget _buildDetailsCard(bool isSaving, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Tiêu đề + Nút Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isMobile)
                const SizedBox()
              else
                _buildSaveButton(
                  isSaving,
                ), // Trên Mobile nút save có thể để xuống dưới nếu chật
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _buildSaveButton(isSaving),
            ),
          ],

          const SizedBox(height: 24),

          // SỬA: Dùng hàm _buildResponsiveRow để tự động xuống dòng

          // 1. Code & Email
          _buildResponsiveInputRow(
            isMobile,
            FitHubLabelInput(
              label: "Employee Code",
              hintText: "",
              controller: _codeCtrl,
              isReadOnly: true,
            ),
            FitHubLabelInput(
              label: "Email Address",
              hintText: "",
              controller: _emailCtrl,
              isReadOnly: true,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Name & Phone
          _buildResponsiveInputRow(
            isMobile,
            FitHubLabelInput(
              label: "Full Name",
              hintText: "Enter name",
              controller: _nameCtrl,
            ),
            FitHubLabelInput(
              label: "Phone Number",
              hintText: "Enter phone",
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Address & Birthday
          _buildResponsiveInputRow(
            isMobile,
            FitHubLabelInput(
              label: "Address",
              hintText: "Enter address",
              controller: _addressCtrl,
            ),
            FitHubLabelInput(
              label: "Birthday",
              hintText: "Select date",
              controller: _birthdayCtrl,
              isReadOnly: true, // Readonly input, nhưng tap để mở DatePicker
              onTap: _pickDate, // Nhớ gọi hàm _pickDate
              suffixIcon: const Icon(Icons.calendar_today, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Nút Save tách riêng
  Widget _buildSaveButton(bool isSaving) {
    return ElevatedButton.icon(
      onPressed: isSaving ? null : _handleSave, // Nhớ gọi hàm _handleSave
      icon: isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.save, size: 18, color: Colors.white),
      label: const Text("Save Changes", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  // --- HÀM HELPER QUAN TRỌNG: Tự động đổi Row/Column ---
  Widget _buildResponsiveInputRow(bool isMobile, Widget input1, Widget input2) {
    if (isMobile) {
      // Mobile: Xếp dọc
      return Column(
        children: [
          input1,
          const SizedBox(height: 16), // Khoảng cách dọc
          input2,
        ],
      );
    } else {
      // Web: Xếp ngang
      return Row(
        children: [
          Expanded(child: input1),
          const SizedBox(width: 16), // Khoảng cách ngang
          Expanded(child: input2),
        ],
      );
    }
  }
}
