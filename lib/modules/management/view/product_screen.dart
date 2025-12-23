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

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().initData();
    });
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
              onSearchChanged: (val) {},
              onFilterTap: () {},
              onExportTap: () {},

              // KHI BẤM NÚT NEW PRODUCT -> CHUYỂN TRANG
              onCreateTap: () {
                context.go('/products/add');
              },
              createLabel: "New Product",
            ),
            const SizedBox(height: 24),

            // --- TABS ---
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
            const SizedBox(height: 24),

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

                  isSelected: (item) => false, // Tạm thời tắt logic select
                  onSelectRow: (item, val) {},
                  onSelectAll: (val) {}, // Logic select all làm sau
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
                            // Kiểm tra nếu có ảnh thì hiện, không thì hiện icon
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
                    Text("\$${NumberFormat("#,##0").format(item.price)}"),
                    Text("${item.stock}"),
                    Text(item.categoryName),
                    FitHubActionButtons(
                      onView: () {},
                      onEdit: () {},
                      onDelete: () {},
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
                            onEdit: () {},
                            onDelete: () {},
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
