import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format ngày tháng
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/fit_hub_filter_tabs.dart';
import 'package:fithub_admin/core/components/common/fit_hub_toolbar.dart';
import 'package:fithub_admin/core/components/common/table/fit_hub_data_table.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/data/models/product_model.dart'; // Import Model
import 'package:fithub_admin/modules/management/view_model/product_view_model.dart'; // Import VM
import 'package:go_router/go_router.dart';
import 'dart:async'; // Thêm thư viện để sử dụng Timer

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Timer? _debounce; // Biến Timer để xử lý trễ

  @override
  void dispose() {
    _debounce?.cancel(); // Hủy timer khi thoát màn hình
    super.dispose();
  }

  // Hàm xử lý search với debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Chờ 500ms sau khi ngừng gõ mới gọi API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductViewModel>().searchProduct(query);
    });
  }

  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().initData();
    });
  }

  // Hàm hiện popup xác nhận
  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product"),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            children: [
              const TextSpan(text: "Are you sure you want to delete "),
              TextSpan(
                text: product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "? This action cannot be undone."),
            ],
          ),
        ),
        actions: [
          // Nút Hủy
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          // Nút Xóa
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog trước

              // Gọi ViewModel xóa
              final success = await context
                  .read<ProductViewModel>()
                  .deleteProduct(product.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to delete product"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu từ ViewModel
    final viewModel = context.watch<ProductViewModel>();
    final products = viewModel.products;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Text("Product", style: AppTextStyles.headingStyle(size: 28)),
            const SizedBox(height: 8),
            FitHubBreadcrumb(
              items: [
                BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
                BreadcrumbItem(title: "Product", route: "/products"),
                BreadcrumbItem(title: "Sneakers", route: null),
              ],
            ),
            const SizedBox(height: 24),

            // --- TOOLBAR ---
            FitHubToolbar(
              hintText: "Search for id, name product",
              onSearchChanged: _onSearchChanged,
              onFilterTap: () {},
              onExportTap: () {},

              // KHI BẤM NÚT NEW PRODUCT -> CHUYỂN TRANG
              onCreateTap: () {
                context.go('/products/form');
              },
              createLabel: "New Product",
            ),
            const SizedBox(height: 24),

            if (viewModel.categories.isNotEmpty || viewModel.tabs.length > 1)
              FitHubFilterTabs(
                selectedIndex: viewModel.selectedTabIndex,
                tabs: viewModel
                    .tabs, // Tabs lấy từ API: ["All Product", "Tai nghe", "Túi"...]
                onTabSelected: (index) {
                  // Gọi ViewModel xử lý
                  context.read<ProductViewModel>().filterByCategory(index);
                },
              ),
            const SizedBox(height: 12),
            // --- BULK ACTION ---
            if (viewModel.selectedIds.isNotEmpty)
              Row(
                children: [
                  Text(
                    "${viewModel.selectedIds.length} items selected",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Selected"),
                          content: Text(
                            "Are you sure you want to delete ${viewModel.selectedIds.length} items?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final success = await context
                                    .read<ProductViewModel>()
                                    .deleteSelectedProducts();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Deleted successfully"
                                            : "Failed to delete some items",
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                "Delete All",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      "Delete Selected",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // --- DATA TABLE ---
            // Xử lý Loading / Error / Data
            if (viewModel.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (viewModel.errorMessage != null)
              Expanded(
                child: Center(child: Text("Error: ${viewModel.errorMessage}")),
              )
            else if (products.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("No products found in this category"),
                ),
              )
            else
              Expanded(
                child: FitHubDataTable<ProductModel>(
                  // Định nghĩa cột
                  columns: [
                    FitHubColumn(label: "Product", flex: 3),
                    FitHubColumn(label: "Price", flex: 1, isSortable: true),
                    FitHubColumn(label: "Stock", flex: 1, isSortable: true),
                    FitHubColumn(label: "Category", flex: 1),
                    FitHubColumn(label: "Action", flex: 1),
                  ],

                  data: products, // Truyền List Model vào

                  isSelected: (item) => viewModel.selectedIds.contains(item.id),
                  onSelectRow: (item, val) {
                    context.read<ProductViewModel>().toggleProductSelection(
                      item.id,
                    );
                  },
                  onSelectAll: (val) {
                    context.read<ProductViewModel>().toggleSelectAll(
                      val ?? false,
                    );
                  },
                  currentPage: 1,
                  totalPages: 1, // API chưa có paging, tạm để 1
                  onPageChanged: (page) {},

                  // WEB BUILDER
                  webRowBuilder: (item) => [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: item.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(item.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "#${item.id}",
                                style: const TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 2. Price (Giữ nguyên)
                    Text("\$${NumberFormat("#,##0").format(item.price)}"),

                    // 3. Stock (Giữ nguyên)
                    Text("${item.stock}"),

                    // 4. Category (Giữ nguyên)
                    Text(item.categoryName),

                    // ---------------------------------------------------------
                    // 👇 5. STATUS (CẬP NHẬT PHẦN NÀY) 👇
                    // Thay thế FitHubStatusBadge bằng Switch
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale:
                              0.8, // Thu nhỏ Switch lại một chút cho gọn bảng
                          child: Switch(
                            value: item.active,
                            activeColor: Colors.green, // Màu khi Active
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade300,
                            onChanged: (val) {
                              // Gọi ViewModel để cập nhật trạng thái
                              context
                                  .read<ProductViewModel>()
                                  .toggleProductStatus(item);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.active ? "Active" : "Hidden",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.active ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // ---------------------------------------------------------

                    // 6. Action Buttons (Giữ nguyên)
                    FitHubActionButtons(
                      onView: () {},
                      onEdit: () => context.go('/products/form/${item.id}'),
                      onDelete: () => _confirmDelete(item),
                    ),
                  ],

                  // MOBILE HEADER
                  mobileHeaderBuilder: (item) => Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: item.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrl == null
                            ? const Icon(Icons.image, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "#${item.id}",
                              style: const TextStyle(
                                color: AppColors.info,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // MOBILE DETAIL
                  mobileDetailBuilder: (item) => Column(
                    children: [
                      _buildMobileRow(
                        "Price",
                        "\$${NumberFormat("#,##0").format(item.price)}",
                      ),
                      _buildMobileRow("Stock", "${item.stock}"),
                      _buildMobileRow("Category", item.categoryName),

                      // ---------------------------------------------------------
                      // 👇 STATUS ROW (CẬP NHẬT PHẦN NÀY) 👇
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Row(
                              children: [
                                Text(
                                  item.active ? "Active" : "Hidden",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: item.active
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height:
                                      24, // Giới hạn chiều cao switch trên mobile
                                  child: Switch(
                                    value: item.active,
                                    activeColor: Colors.green,
                                    onChanged: (val) {
                                      context
                                          .read<ProductViewModel>()
                                          .toggleProductStatus(item);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ---------------------------------------------------------
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Action: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FitHubActionButtons(
                            onView: () {},
                            onEdit: () =>
                                context.go('/products/form/${item.id}'),
                            onDelete: () => _confirmDelete(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
