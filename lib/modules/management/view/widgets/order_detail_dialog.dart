import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fithub_admin/configs/app_colors.dart';
import 'package:fithub_admin/configs/app_responsive.dart';
import 'package:fithub_admin/core/components/common/table/table_components.dart';
import 'package:fithub_admin/data/models/order_model.dart';
import 'package:fithub_admin/modules/management/view_model/order_view_model.dart';

class OrderDetailDialog extends StatefulWidget {
  final OrderModel order;
  const OrderDetailDialog({super.key, required this.order});

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  late String _currentStatus;
  bool _isLoading = false;

  final List<String> _statuses = [
    "NEW",
    "CONFIRMED",
    "DELIVERING",
    "DONE",
    "CANCEL",
  ];

  // Logic kiểm tra xem đơn hàng có bị "khóa" không
  bool get _isOrderLocked => ["DONE", "CANCEL"].contains(widget.order.status);

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _handleUpdateStatus() async {
    // Chặn logic (Double check)
    if (_isOrderLocked) return;
    if (_currentStatus == widget.order.status) return; // Chưa đổi gì thì thôi

    setState(() => _isLoading = true);

    final success = await context.read<OrderViewModel>().updateStatus(
      widget.order.id,
      _currentStatus,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Status updated!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Update failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check mobile để chỉnh layout
    final isMobile = Responsive.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${widget.order.id}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // List Items
            const Text(
              "Order Items:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200, // Fixed height for scrollable list
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: widget.order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.shopping_bag, size: 20),
                      ),
                    ),
                    title: Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${NumberFormat("#,##0").format(item.price)} x ${item.quantity}",
                    ),
                    trailing: Text(
                      NumberFormat("#,##0").format(item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- PHẦN SỬA LỖI OVERFLOW ---
            _buildTotalAndStatus(isMobile),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Nếu Locked thì disable nút (null)
                onPressed: (_isLoading || _isOrderLocked)
                    ? null
                    : _handleUpdateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  disabledBackgroundColor:
                      Colors.grey.shade300, // Màu khi bị disable
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        _isOrderLocked
                            ? "Order is Closed"
                            : "Update Order Status", // Đổi text nút
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi đơn hàng đã khóa (Không cho sửa)
  Widget _buildLockedStatusLabel(String status) {
    // Tái sử dụng Badge có sẵn hoặc Text thường
    if (status == "DONE") return FitHubStatusBadge.success("DONE");
    if (status == "CANCEL") return FitHubStatusBadge.error("CANCEL");
    return Text(
      status,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }

  // Widget Dropdown cho phép sửa
  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus,
          items: _statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _currentStatus = val);
          },
        ),
      ),
    );
  }

  // Widget tách riêng để xử lý Responsive
  Widget _buildTotalAndStatus(bool isMobile) {
    // 1. Widget hiển thị Tổng tiền
    final totalWidget = Text(
      "Total: ${NumberFormat("#,##0").format(widget.order.totalAmount)}",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );

    // 2. Widget hiển thị Status Dropdown
    final statusWidget = Row(
      mainAxisSize: MainAxisSize.min, // Quan trọng để không chiếm hết chỗ
      children: [
        const Text("Status: "),
        const SizedBox(width: 8),
        _isOrderLocked
            ? _buildLockedStatusLabel(_currentStatus)
            : _buildStatusDropdown(),
      ],
    );

    // 3. Logic Responsive
    if (isMobile) {
      // Mobile: Xếp dọc (Column)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          totalWidget,
          const SizedBox(height: 12), // Khoảng cách giữa 2 dòng
          statusWidget,
        ],
      );
    } else {
      // Web: Xếp ngang (Row)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [totalWidget, statusWidget],
      );
    }
  }
}
