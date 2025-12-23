import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/fit_hub_toolbar.dart';
import 'package:fithub_admin/core/components/common/table/fit_hub_data_table.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/modules/management/view_model/category_view_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();
    final categories = viewModel.categories;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Text("Category", style: AppTextStyles.headingStyle(size: 28)),
            const SizedBox(height: 8),
            FitHubBreadcrumb(
              items: [
                BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
                BreadcrumbItem(title: "Category", route: null),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Toolbar
            FitHubToolbar(
              hintText: "Search category...",
              createLabel: "New Category",
              onCreateTap: () {
                // Mở dialog tạo mới (Làm sau)
                print("Create Category");
              },
              onSearchChanged: (val) {
                // Logic search local nếu cần
              },
            ),
            const SizedBox(height: 24),

            // 3. Table
            if (viewModel.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (viewModel.errorMessage != null)
              Expanded(
                child: Center(child: Text("Error: ${viewModel.errorMessage}")),
              )
            else
              Expanded(
                child: FitHubDataTable<CategoryModel>(
                  columns: [
                    FitHubColumn(label: "ID", flex: 1),
                    FitHubColumn(label: "Name", flex: 2, isSortable: true),
                    FitHubColumn(label: "Description", flex: 4),
                    FitHubColumn(label: "Status", flex: 1),
                    FitHubColumn(label: "Action", flex: 1),
                  ],
                  data: categories,

                  // Web Builder
                  webRowBuilder: (item) => [
                    Text(
                      "#${item.id}",
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    item.active
                        ? FitHubStatusBadge.success("Active")
                        : FitHubStatusBadge.error("Inactive"),
                    FitHubActionButtons(
                      onEdit: () {
                        /* Edit logic */
                      },
                      onDelete: () {
                        /* Delete logic */
                      },
                    ),
                  ],

                  // Mobile Header
                  mobileHeaderBuilder: (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#${item.id}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Mobile Detail
                  mobileDetailBuilder: (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _mobileRow("Description", item.description),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(color: Colors.grey),
                          ),
                          item.active
                              ? FitHubStatusBadge.success("Active")
                              : FitHubStatusBadge.error("Inactive"),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Action: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FitHubActionButtons(onEdit: () {}, onDelete: () {}),
                        ],
                      ),
                    ],
                  ),

                  // Các config khác
                  isSelected: (item) => false,
                  onSelectRow: (item, val) {},
                  onSelectAll: (val) {},
                  currentPage: 1,
                  totalPages: 1,
                  onPageChanged: (page) {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
