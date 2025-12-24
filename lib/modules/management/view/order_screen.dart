import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_text_styles.dart';
import 'package:fithub_admin/core/components/common/fit_hub_breadcrumb.dart';
import 'package:fithub_admin/core/components/common/fit_hub_filter_tabs.dart';
import 'package:fithub_admin/core/components/common/fit_hub_toolbar.dart';
import 'package:fithub_admin/core/components/common/table/fit_hub_data_table.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/data/models/order_model.dart';
import 'package:fithub_admin/modules/management/view/widgets/order_detail_dialog.dart';
import 'package:fithub_admin/modules/management/view_model/order_view_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().initData();
    });
  }

  // Helper chọn màu Badge cho Status
  Widget _buildStatusBadge(String status) {
    switch (status) {
      case "NEW":
        return FitHubStatusBadge(
          label: status,
          color: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        );
      case "CONFIRMED":
        return FitHubStatusBadge(
          label: status,
          color: Colors.orange,
          backgroundColor: Colors.orange.shade50,
        );
      case "DELIVERING":
        return FitHubStatusBadge(
          label: status,
          color: Colors.purple,
          backgroundColor: Colors.purple.shade50,
        );
      case "DONE":
        return FitHubStatusBadge.success(status);
      case "CANCEL":
        return FitHubStatusBadge.error(status);
      default:
        return FitHubStatusBadge(
          label: status,
          color: Colors.grey,
          backgroundColor: Colors.grey.shade100,
        );
    }
  }

  void _openDetail(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final orders = viewModel.filteredOrders;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Orders", style: AppTextStyles.headingStyle(size: 28)),
            const SizedBox(height: 8),
            FitHubBreadcrumb(
              items: [
                BreadcrumbItem(title: "Dashboard", route: "/dashboard"),
                BreadcrumbItem(title: "Orders", route: null),
              ],
            ),
            const SizedBox(height: 24),

            // Toolbar (Ẩn nút Create vì Order được tạo từ App User)
            FitHubToolbar(
              hintText: "Search order ID...",
              // Không truyền onCreateTap để ẩn nút New
            ),
            const SizedBox(height: 24),

            // Tabs (Client-side Filter)
            FitHubFilterTabs(
              selectedIndex: viewModel.selectedTabIndex,
              tabs: viewModel.tabs.map((t) {
                // Có thể thêm số lượng vào tab: "NEW (5)" nếu muốn
                return t;
              }).toList(),
              onTabSelected: (index) => viewModel.filterByTab(index),
            ),
            const SizedBox(height: 24),

            // Table
            if (viewModel.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (viewModel.errorMessage != null)
              Expanded(
                child: Center(child: Text("Error: ${viewModel.errorMessage}")),
              )
            else
              Expanded(
                child: FitHubDataTable<OrderModel>(
                  columns: [
                    FitHubColumn(label: "Order ID", flex: 1),
                    FitHubColumn(label: "Products", flex: 3),
                    FitHubColumn(label: "Date", flex: 2),
                    FitHubColumn(label: "Total", flex: 1, isSortable: true),
                    FitHubColumn(label: "Status", flex: 1),
                    FitHubColumn(label: "Action", flex: 1),
                  ],
                  data: orders,

                  // Web Builder
                  webRowBuilder: (item) => [
                    Text(
                      "#${item.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.productSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat(
                        "dd/MM/yyyy HH:mm",
                      ).format(item.createdAt ?? DateTime.now()),
                    ),
                    Text(NumberFormat("#,##0").format(item.totalAmount)),
                    _buildStatusBadge(item.status),
                    FitHubActionButtons(
                      onView: () => _openDetail(item),
                      onEdit: () =>
                          _openDetail(item), // Edit status cũng là view detail
                      // Order thường ít khi xóa cứng, nên ẩn nút delete hoặc gắn logic nếu cần
                    ),
                  ],

                  // Mobile Builders
                  mobileHeaderBuilder: (item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${item.id}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        NumberFormat("#,##0").format(item.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  mobileDetailBuilder: (item) => Column(
                    children: [
                      _mobileRow("Products", item.productSummary),
                      _mobileRow(
                        "Date",
                        DateFormat(
                          "dd/MM/yyyy",
                        ).format(item.createdAt ?? DateTime.now()),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(color: Colors.grey),
                          ),
                          _buildStatusBadge(item.status),
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
                          FitHubActionButtons(
                            onView: () => _openDetail(item),
                            onEdit: () => _openDetail(item),
                          ),
                        ],
                      ),
                    ],
                  ),

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
