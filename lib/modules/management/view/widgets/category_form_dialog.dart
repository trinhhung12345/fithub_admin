import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/modules/management/view_model/category_view_model.dart';
import 'package:fithub_admin/data/models/category_model.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category; // Thêm tham số này

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _status = 1; // UI vẫn dùng Int (1: Active, 0: Inactive) cho Dropdown
  bool _isLoading = false;

  // Getter để check chế độ
  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    // Nếu là Edit -> Fill dữ liệu cũ vào
    if (isEditMode) {
      _nameController.text = widget.category!.name;
      _descController.text = widget.category!.description;
      // Convert từ bool (Model) sang int (UI)
      _status = widget.category!.active ? 1 : 0;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = false;
      final vm = context.read<CategoryViewModel>();

      if (isEditMode) {
        // --- UPDATE LOGIC ---
        success = await vm.updateCategory(
          id: widget.category!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _status == 1, // Convert int UI -> bool API
        );
      } else {
        // --- CREATE LOGIC ---
        success = await vm.createCategory(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _status, // Create API dùng int
        );
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode ? "Updated successfully!" : "Created successfully!",
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Action failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Đổi tiêu đề động
              Text(
                isEditMode ? "Update Category" : "Add New Category",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              FitHubLabelInput(
                label: "Category Name",
                hintText: "e.g. Dụng cụ thể thao",
                controller: _nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Description
              FitHubLabelInput(
                label: "Description",
                hintText: "Description...",
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Status
              FitHubSelectInput<int>(
                label: "Status",
                hintText: "Select status",
                value: _status,
                items: const [1, 0],
                itemLabelBuilder: (val) => val == 1 ? "Active" : "Inactive",
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEditMode
                                ? "Save Changes"
                                : "Create", // Đổi text nút
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
