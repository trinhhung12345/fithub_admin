class OrderItemModel {
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String status; // "NEW", "CONFIRMED", ...
  final double totalAmount;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'NEW',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Fallback now nếu null
      items: itemsList,
    );
  }

  // Helper để hiển thị tóm tắt sản phẩm trên bảng
  String get productSummary {
    if (items.isEmpty) return "No items";
    if (items.length == 1) return items.first.productName;
    return "${items.first.productName} + ${items.length - 1} others";
  }
}
