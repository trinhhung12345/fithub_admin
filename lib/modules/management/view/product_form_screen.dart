import 'dart:io';
import 'package:flutter/foundation.dart'; // check kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Components
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_image_picker.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_tag_input.dart';
import 'package:fithub_admin/core/components/layout/fit_hub_form_scaffold.dart';

// Models & Services
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/models/product_tag.dart';
import 'package:fithub_admin/data/services/product_service.dart';
import 'package:fithub_admin/modules/management/view_model/product_view_model.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId; // null = Create, có ID = Edit

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

  // State Variables
  bool get isEditMode => widget.productId != null;
  bool _isLoading = false;

  // Data Lists
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  // Tags
  List<ProductTag> _tags = []; // Tag sẽ gửi đi
  List<ProductTag> _initialTags = []; // Tag ban đầu (để hiển thị khi edit)

  // Status
  bool _isActive = true; // Mặc định là Active

  // Images Logic
  // _displayImages: Chứa cả String (Url cũ) và XFile (Ảnh mới) để hiển thị UI
  List<dynamic> _displayImages = [];
  // _newImagesToUpload: Chỉ chứa XFile để gửi lên API
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

  // --- INIT DATA ---
  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Categories (Ưu tiên lấy từ Cache ViewModel)
      final vm = context.read<ProductViewModel>();
      if (vm.categories.isNotEmpty) {
        _categories = vm.categories;
      } else {
        _categories = await _service.getCategories();
      }

      // 2. Nếu là Edit Mode -> Load chi tiết sản phẩm
      if (isEditMode) {
        await _loadProductDetail();
      }
    } catch (e) {
      print("Error init data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOAD DETAIL FOR EDIT ---
  Future<void> _loadProductDetail() async {
    final int id = int.parse(widget.productId!);
    final product = await _service.getProductDetail(id);

    if (product != null) {
      // Fill Text Fields
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(0);
      _qtyController.text = product.stock.toString();

      // Fill Category
      try {
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == product.categoryId,
        );
      } catch (_) {}

      // Fill Status
      _isActive = product.active;

      // Fill Images (Ảnh cũ từ Server)
      if (product.fileUrls.isNotEmpty) {
        setState(() {
          _displayImages = List.from(product.fileUrls);
        });
      }

      // Fill Tags
      if (product.tags.isNotEmpty) {
        setState(() {
          _initialTags = List.from(product.tags);
          _tags = List.from(
            product.tags,
          ); // Sync luôn để nếu không sửa gì thì vẫn gửi tag cũ
        });
      }
    }
  }

  // --- IMAGE ACTIONS ---
  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImagesToUpload.addAll(pickedFiles);
          _displayImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print("Pick image error: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      final item = _displayImages[index];
      _displayImages.removeAt(index);

      // Nếu là ảnh mới thì xóa khỏi list upload
      if (item is XFile) {
        _newImagesToUpload.remove(item);
      }
      // Nếu là ảnh cũ (String URL), logic hiện tại là xóa khỏi UI.
      // (Backend cần logic riêng để xóa file cũ nếu cần, ở đây ta chỉ gửi update thông tin mới)
    });
  }

  // --- SUBMIT ---
  Future<void> _handleSubmit() async {
    // Validate cơ bản
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill required fields (Name, Price, Category)"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = false;
      final double price = double.tryParse(_priceController.text) ?? 0;
      final int stock = int.tryParse(_qtyController.text) ?? 0;

      if (isEditMode) {
        // --- UPDATE ---
        success = await _service.updateProduct(
          id: int.parse(widget.productId!),
          name: _nameController.text,
          description: _descController.text,
          price: price,
          stock: stock,
          categoryId: _selectedCategory!.id,
          active: _isActive, // Gửi trạng thái active
          tags: _tags,
          newImages: _newImagesToUpload,
        );
      } else {
        // --- CREATE ---
        success = await _service.createProduct(
          name: _nameController.text,
          description: _descController.text,
          price: price,
          stock: stock,
          categoryId: _selectedCategory!.id,
          // Mặc định create là active=true, nhưng nếu muốn tùy chỉnh thì truyền _isActive
          // Bạn cần update hàm createProduct trong service để nhận active nếu muốn
          // Ở đây giả sử createProduct mặc định active=true, hoặc bạn đã update service rồi
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
      // Header
      title: isEditMode ? "Edit Product" : "Add Product",
      breadcrumbs: [
        BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
        BreadcrumbItem(title: "Product", route: "/products"),
        BreadcrumbItem(
          title: isEditMode ? "Edit #${widget.productId}" : "Add Product",
          route: null,
        ),
      ],

      // Actions
      isLoading: _isLoading,
      onSave: _handleSubmit,
      onDiscard: () => context.pop(),

      // SIDE INFO: Images
      sideInfo: FitHubImagePicker(
        images: _displayImages.map((e) {
          // Convert XFile sang File (Mobile) hoặc String Path (Web)
          if (e is XFile) return kIsWeb ? e.path : File(e.path);
          return e; // String URL cũ
        }).toList(),
        onAddTap: _pickImage,
        onRemoveTap: _removeImage,
      ),

      // MAIN INFO: Form Fields
      mainInfo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Stock Quantity
          FitHubLabelInput(
            label: "Stock Quantity",
            hintText: "Input stock",
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // --- 🆕 STATUS SWITCH ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Active Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive
                          ? "Product will be visible"
                          : "Product will be hidden",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Switch(
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          FitHubLabelInput(
            label: "Description",
            hintText: "Product details...",
            controller: _descController,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Tags
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: FitHubTagInput(
              initialTags: _initialTags, // Truyền tag cũ vào nếu có
              onTagsChanged: (tags) {
                _tags = tags;
              },
            ),
          ),
        ],
      ),
    );
  }
}
