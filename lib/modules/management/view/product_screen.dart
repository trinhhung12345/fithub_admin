import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format ngày tháng
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/fit_hub_filter_tabs.dart';
import 'package:fithub_admin/core/components/common/fit_hub_toolbar.dart';
import 'package:fithub_admin/core/components/common/table/fit_hub_data_table.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/data/models/product_model.dart'; // Import Model
import 'package:fithub_admin/data/mocks/mock_product_data.dart'; // Import Mock
import 'package:go_router/go_router.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // 1. Lấy dữ liệu từ file Mock
  final List<ProductModel> _products = MockProductData.products;

  // 2. Quản lý trạng thái chọn
  final Set<String> _selectedIds = {};
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
            FitHubFilterTabs(
              selectedIndex: _selectedTabIndex,
              tabs: const [
                "Sneakers (50)",
                "Jacket (26)",
                "T-Shirt (121)",
                "Bag (21)",
              ],
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
            ),
            const SizedBox(height: 24),

            // --- DATA TABLE ---
            Expanded(
              child: FitHubDataTable<ProductModel>(
                // Định nghĩa cột
                columns: [
                  FitHubColumn(label: "Product", flex: 3),
                  FitHubColumn(label: "Price", flex: 1, isSortable: true),
                  FitHubColumn(label: "Size", flex: 1, isSortable: true),
                  FitHubColumn(label: "QTY", flex: 1, isSortable: true),
                  FitHubColumn(label: "Date", flex: 2, isSortable: true),
                  FitHubColumn(label: "Status", flex: 2, isSortable: true),
                  FitHubColumn(label: "Action", flex: 2),
                ],

                data: _products, // Truyền List Model vào

                isSelected: (item) => _selectedIds.contains(item.id),
                onSelectRow: (item, val) {
                  setState(() {
                    val!
                        ? _selectedIds.add(item.id)
                        : _selectedIds.remove(item.id);
                  });
                },
                onSelectAll: (val) {}, // Logic select all làm sau
                currentPage: 1,
                totalPages: 13,
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
                          image: DecorationImage(
                            image: NetworkImage(item.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.id,
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
                  Text("${item.size}"),
                  Text("${item.qty}"),
                  Text(
                    DateFormat("MM/dd/yy 'at' h:mm a").format(item.date),
                    style: const TextStyle(fontSize: 12),
                  ),
                  item.status == "Available"
                      ? FitHubStatusBadge.success("Available")
                      : FitHubStatusBadge.error("Out of Stock"),
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
                        image: DecorationImage(
                          image: NetworkImage(item.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.id,
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                    _buildMobileRow("Size", "${item.size}"),
                    _buildMobileRow("QTY", "${item.qty}"),
                    _buildMobileRow(
                      "Date",
                      DateFormat("dd/MM/yyyy").format(item.date),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(color: Colors.grey),
                          ),
                          item.status == "Available"
                              ? FitHubStatusBadge.success("Available")
                              : FitHubStatusBadge.error("Out of Stock"),
                        ],
                      ),
                    ),
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
