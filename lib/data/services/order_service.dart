import 'package:fithub_admin/data/services/api_service.dart';
import 'package:fithub_admin/data/models/order_model.dart';

class OrderService extends ApiService {
  // 1. Get All Orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await dio.get('/orders');

      if (response.statusCode == 200) {
        // API trả về mảng trực tiếp: [...]
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error get orders: $e");
      rethrow;
    }
  }

  // 2. Update Order Status
  Future<bool> updateOrderStatus(int id, String newStatus) async {
    try {
      final response = await dio.put(
        '/orders/$id', // Hoặc endpoint riêng tùy backend (ví dụ: /orders/$id/status)
        data: {
          "status": newStatus, // Gửi status mới lên
        },
      );

      // Check success code (200 hoặc 204)
      return response.statusCode == 200;
    } catch (e) {
      print("Error update order status: $e");
      return false;
    }
  }
}
