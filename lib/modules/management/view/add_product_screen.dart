import 'dart:io'; // Để hiển thị ảnh file trên mobile
import 'package:flutter/foundation.dart'; // check kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:provider/provider.dart';

// Components
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_image_picker.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_tag_input.dart'; // Tag Input Mới
import 'package:fithub_admin/core/components/common/form/fit_hub_form_scaffold.dart';

// Service & Models
import 'package:fithub_admin/data/services/product_service.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/models/product_tag.dart';
import 'package:fithub_admin/modules/management/view_model/product_view_model.dart';

import 'package:fithub_admin/configs/app_colors.dart'; // Để lấy danh sách Category

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _service = ProductService();
  final _picker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  // State Data
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  List<ProductTag> _tags = []; // Danh sách tags
  List<XFile> _selectedImages = []; // Danh sách ảnh đã chọn (XFile)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lấy danh sách category từ ViewModel (hoặc gọi API lại nếu muốn chắc chắn)
    final vm = context.read<ProductViewModel>();
    if (vm.categories.isNotEmpty) {
      _categories = vm.categories;
    } else {
      // Fallback: Gọi API lấy category nếu ViewModel chưa có
      _service.getCategories().then((value) {
        setState(() => _categories = value);
      });
    }
  }

  // Chọn ảnh
  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          // Giới hạn 4 ảnh hiển thị cho đẹp layout (nhưng list thực tế vẫn giữ đủ để gửi)
          if (_selectedImages.length > 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Warning: Only first 4 images shown, but all will be uploaded",
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Lưu sản phẩm
  Future<void> _handleSave() async {
    // Validate sơ bộ
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.createProduct(
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        stock: int.tryParse(_qtyController.text) ?? 0,
        categoryId: _selectedCategory!.id,
        tags: _tags,
        images: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success!"),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Quay lại trang list
        context.read<ProductViewModel>().initData(); // Reload lại list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FitHubFormScaffold(
      title: "Add Product",
      breadcrumbs: [
        BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
        BreadcrumbItem(title: "Product", route: "/products"),
        BreadcrumbItem(title: "Add Product", route: null),
      ],
      isLoading: _isLoading,
      onSave: _handleSave,
      onDiscard: () => context.pop(),

      // --- SIDE INFO: IMAGE PICKER ---
      sideInfo: FitHubImagePicker(
        // Convert List<XFile> sang List hiển thị được (String path hoặc File)
        images: _selectedImages
            .map((e) => kIsWeb ? e.path : File(e.path))
            .toList(),
        onImageTap: (index) {
          // Nếu bấm vào slot, mở picker
          _pickImage();
        },
      ),

      // --- MAIN INFO ---
      mainInfo: Column(
        children: [
          // Name
          FitHubLabelInput(
            label: "Product Name",
            hintText: "Input product name",
            controller: _nameController,
          ),
          const SizedBox(height: 16),

          // Row: Category & Price
          Row(
            children: [
              Expanded(
                child: FitHubSelectInput<CategoryModel>(
                  label: "Category",
                  hintText: "Select category",
                  items: _categories,
                  value: _selectedCategory,
                  itemLabelBuilder: (cat) => cat.name,
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FitHubLabelInput(
                  label: "Price",
                  hintText: "Input Price",
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffixIcon: const Icon(Icons.attach_money, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantity
          FitHubLabelInput(
            label: "Stock Quantity",
            hintText: "Input stock",
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // Description
          FitHubLabelInput(
            label: "Description",
            hintText: "Product details...",
            controller: _descController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // --- TAGS INPUT (COMPONENT MỚI) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: FitHubTagInput(
              onTagsChanged: (tags) {
                _tags = tags; // Cập nhật list tag để gửi đi
              },
            ),
          ),
        ],
      ),
    );
  }
}
