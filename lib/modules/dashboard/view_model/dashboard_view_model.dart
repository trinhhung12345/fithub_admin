import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/order_model.dart';
import 'package:fithub_admin/data/services/order_service.dart';
import 'package:fithub_admin/data/services/product_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  // Các chỉ số KPI
  double totalRevenue = 0.0;
  int totalOrders = 0;
  int newOrdersCount = 0;
  int totalProducts = 0;

  // Dữ liệu cho Biểu đồ: Map<Status, Số lượng>
  Map<String, double> orderStatusMap = {};

  // Dữ liệu cho Bảng Recent Orders
  List<OrderModel> recentOrders = [];

  bool isLoading = false;

  Future<void> initData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Gọi song song 2 API để tiết kiệm thời gian
      final results = await Future.wait([
        _orderService.getAllOrders(),
        _productService.getProducts(),
      ]);

      final orders = results[0] as List<OrderModel>;
      final products = results[1] as List<dynamic>; // Product list

      // 1. Tính Tổng đơn hàng
      totalOrders = orders.length;

      // 2. Tính Tổng sản phẩm
      totalProducts = products.length;

      // 3. Tính Doanh thu (Chỉ tính các đơn KHÔNG BỊ HỦY)
      // Giả sử logic là đơn CONFIRMED/DONE/DELIVERING mới tính tiền,
      // hoặc đơn giản là status != CANCEL tùy nghiệp vụ của bạn.
      // Ở đây tôi tính tất cả trừ CANCEL.
      totalRevenue = orders
          .where((o) => o.status != "CANCEL")
          .fold(0.0, (sum, item) => sum + item.totalAmount);

      // 4. Đếm số đơn mới cần xử lý
      newOrdersCount = orders.where((o) => o.status == "NEW").length;

      // --- LOGIC MỚI (CHART & LIST) ---

      // 1. Tính toán data cho Pie Chart
      orderStatusMap = {};
      for (var order in orders) {
        // Đếm số lượng từng status
        orderStatusMap[order.status] = (orderStatusMap[order.status] ?? 0) + 1;
      }

      // 2. Lấy 5 đơn hàng mới nhất (Status = NEW, Sắp xếp ID giảm dần)
      // Nếu muốn lấy 5 đơn bất kỳ mới nhất thì bỏ điều kiện where
      recentOrders = orders.where((o) => o.status == "NEW").toList();

      // Sort mới nhất lên đầu (theo ID hoặc Date)
      recentOrders.sort((a, b) => b.id.compareTo(a.id));

      // Chỉ lấy 5 cái
      if (recentOrders.length > 5) {
        recentOrders = recentOrders.sublist(0, 5);
      }
    } catch (e) {
      // Error is rethrown, no need for print in production
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
