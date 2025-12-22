import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/form/fit_hub_form_scaffold.dart'; // Wrapper
import 'package:fithub_admin/core/components/common/form/fit_hub_image_picker.dart'; // Image
import 'package:fithub_admin/core/components/common/form/fit_hub_label_input.dart'; // Input
import 'package:fithub_admin/core/components/common/form/fit_hub_select_input.dart'; // Select

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers & State
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  String? _selectedCategory;
  final List<String> _images = []; // List ảnh

  @override
  Widget build(BuildContext context) {
    return FitHubFormScaffold(
      // 1. Cấu hình Header
      title: "Add Product",
      breadcrumbs: [
        BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
        BreadcrumbItem(title: "Product", route: "/products"),
        BreadcrumbItem(title: "Add Product"),
      ],

      // 2. Cấu hình Form Chính (Bên trái/Trên)
      mainInfo: Column(
        children: [
          FitHubLabelInput(
            label: "SKU",
            hintText: "Input SKU",
            controller: _skuController,
          ),
          const SizedBox(height: 16),
          FitHubLabelInput(
            label: "Product Name",
            hintText: "Input product name",
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FitHubLabelInput(
                  label: "Price",
                  hintText: "Input Price",
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("\$"),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FitHubLabelInput(
                  label: "Quantity",
                  hintText: "Input stock",
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FitHubSelectInput<String>(
            label: "Category",
            hintText: "Select category",
            value: _selectedCategory,
            items: const ["Sneakers", "Jacket", "T-Shirt"],
            itemLabelBuilder: (val) => val,
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
        ],
      ),

      // 3. Cấu hình Side Panel (Bên phải/Dưới) - Ảnh
      sideInfo: FitHubImagePicker(
        images: _images,
        onImageTap: (index) {
          // Logic pick ảnh
          print("Pick image $index");
        },
      ),

      // 4. Actions
      onSave: () async {
        // Logic gọi API Add Product
        print("Saving...");
      },
      onDiscard: () {
        Navigator.pop(context);
      },
    );
  }
}
