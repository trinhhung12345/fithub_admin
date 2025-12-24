import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/order_model.dart';
import 'package:fithub_admin/data/services/order_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _service = OrderService();

  // Dữ liệu gốc (tất cả đơn hàng từ API)
  List<OrderModel> _allOrders = [];

  // Dữ liệu hiển thị (đã qua lọc)
  List<OrderModel> filteredOrders = [];

  // Tabs trạng thái
  final List<String> tabs = [
    "All",
    "NEW",
    "CONFIRMED",
    "DELIVERING",
    "DONE",
    "CANCEL",
  ];
  int selectedTabIndex = 0;

  bool isLoading = false;
  String? errorMessage;

  Future<void> initData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _service.getAllOrders();
      _applyFilter(); // Lọc dữ liệu ban đầu
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm lọc local
  void filterByTab(int index) {
    selectedTabIndex = index;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (selectedTabIndex == 0) {
      // Tab "All" -> Lấy hết
      filteredOrders = List.from(_allOrders);
    } else {
      // Các tab khác -> Lọc theo string status
      final statusKey = tabs[selectedTabIndex];
      filteredOrders = _allOrders.where((o) => o.status == statusKey).toList();
    }

    // Sắp xếp ID giảm dần (đơn mới nhất lên đầu)
    filteredOrders.sort((a, b) => b.id.compareTo(a.id));
  }

  // Cập nhật trạng thái
  Future<bool> updateStatus(int id, String newStatus) async {
    final success = await _service.updateOrderStatus(id, newStatus);

    if (success) {
      // Update local: Tìm item trong list gốc và sửa status
      final index = _allOrders.indexWhere((o) => o.id == id);
      if (index != -1) {
        // Tạo object mới với status mới (vì fields là final)
        final oldOrder = _allOrders[index];
        _allOrders[index] = OrderModel(
          id: oldOrder.id,
          status: newStatus,
          totalAmount: oldOrder.totalAmount,
          createdAt: oldOrder.createdAt,
          items: oldOrder.items,
        );

        // Apply lại filter để UI cập nhật (ví dụ đang ở tab NEW mà chuyển sang DONE thì nó sẽ mất khỏi tab NEW)
        _applyFilter();
        notifyListeners();
      }
    }
    return success;
  }
}
