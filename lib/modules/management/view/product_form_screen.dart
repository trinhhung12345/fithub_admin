import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Components & Models
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_image_picker.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_tag_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_form_scaffold.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/models/product_model.dart';
import 'package:fithub_admin/data/models/product_tag.dart';
import 'package:fithub_admin/data/services/product_service.dart';
import 'package:fithub_admin/modules/management/view_model/product_view_model.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId; // Nếu null -> Thêm mới, Có ID -> Sửa

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _service = ProductService();
  final _picker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  // State
  bool get isEditMode => widget.productId != null; // Check chế độ
  bool _isLoading = false;

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  List<ProductTag> _tags = [];

  // Quản lý ảnh: Trộn lẫn giữa ảnh cũ (String URL) và ảnh mới (XFile)
  // List này dùng để hiển thị lên UI
  List<dynamic> _displayImages = [];

  // List này dùng để track ảnh mới chọn để upload
  List<XFile> _newImagesToUpload = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    // 1. Load Categories
    try {
      final vm = context.read<ProductViewModel>();
      if (vm.categories.isNotEmpty) {
        _categories = vm.categories;
      } else {
        _categories = await _service.getCategories();
      }

      // 2. Nếu là Edit Mode -> Load Product Detail
      if (isEditMode) {
        await _loadProductDetail();
      }
    } catch (e) {
      print("Error init data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC LOAD DỮ LIỆU ĐỂ SỬA ---
  Future<void> _loadProductDetail() async {
    final int id = int.parse(widget.productId!);
    final product = await _service.getProductDetail(id);

    if (product != null) {
      // 1. Fill Text Controllers
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(0);
      _qtyController.text = product.stock.toString();

      // 2. Fill Category (Tìm object trong list _categories khớp ID)
      try {
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == product.categoryId,
        );
      } catch (e) {
        print("Category ID ${product.categoryId} not found in list");
      }

      // 3. Fill Images (Lấy từ API files)
      // Sử dụng fileUrls đã được parse trong Model
      if (product.fileUrls.isNotEmpty) {
        _displayImages.addAll(product.fileUrls);
      } else if (product.imageUrl != null) {
        _displayImages.add(product.imageUrl);
      }

      // 4. Fill Tags (Nếu có - cần update model để lấy tags)
      // _tags = product.tags...
    }
  }

  // Chọn ảnh mới
  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImagesToUpload.addAll(pickedFiles); // Để gửi API
        _displayImages.addAll(pickedFiles); // Để hiện UI
      });
    }
  }

  // Xóa ảnh
  void _removeImage(int index) {
    setState(() {
      final item = _displayImages[index];
      _displayImages.removeAt(index);

      // Nếu là ảnh mới (XFile) thì xóa khỏi list upload luôn
      if (item is XFile) {
        _newImagesToUpload.remove(item);
      } else {
        // Nếu là ảnh cũ (String URL) -> Cần logic lưu ID để gửi API xóa (Làm sau)
        print("Mark image URL $item as deleted");
      }
    });
  }

  Future<void> _handleSubmit() async {
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
      bool success = false;

      if (isEditMode) {
        // --- LOGIC UPDATE ---
        success = await _service.updateProduct(
          id: int.parse(widget.productId!), // ID lấy từ URL params
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_qtyController.text) ?? 0,
          categoryId: _selectedCategory!.id,
          tags: _tags,
          newImages: _newImagesToUpload, // Chỉ gửi ảnh mới chọn thêm
        );
      } else {
        // --- LOGIC CREATE (Cũ) ---
        success = await _service.createProduct(
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_qtyController.text) ?? 0,
          categoryId: _selectedCategory!.id,
          tags: _tags,
          images: _newImagesToUpload,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? "Updated successfully!" : "Created successfully!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Quay về list
        context.read<ProductViewModel>().initData(); // Reload list
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
      title: isEditMode ? "Edit Product" : "Add Product", // Đổi tiêu đề động
      breadcrumbs: [
        BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
        BreadcrumbItem(title: "Product", route: "/products"),
        BreadcrumbItem(
          title: isEditMode ? "Edit #${widget.productId}" : "Add Product",
          route: null,
        ),
      ],
      isLoading: _isLoading,
      onSave: _handleSubmit,
      onDiscard: () => context.pop(),

      sideInfo: FitHubImagePicker(
        images: _displayImages.map((e) {
          // Logic hiển thị hỗn hợp
          if (e is String) return e; // URL ảnh cũ
          if (e is XFile) return kIsWeb ? e.path : File(e.path); // Ảnh mới
          return e;
        }).toList(),
        onAddTap: _pickImage,
        onRemoveTap: _removeImage,
      ),

      mainInfo: Column(
        children: [
          FitHubLabelInput(
            label: "Product Name",
            hintText: "Input product name",
            controller: _nameController,
          ),
          const SizedBox(height: 16),

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

          FitHubLabelInput(
            label: "Stock Quantity",
            hintText: "Input stock",
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          FitHubLabelInput(
            label: "Description",
            hintText: "Product details...",
            controller: _descController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Tag Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: FitHubTagInput(
              initialTags: _tags, // Truyền tags cũ để hiển thị khi edit
              onTagsChanged: (tags) => _tags = tags,
            ),
          ),
        ],
      ),
    );
  }
}
