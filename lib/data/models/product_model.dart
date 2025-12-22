class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final int size;
  final int qty;
  final DateTime date; // Dùng DateTime để dễ format
  final String status; // "Available" hoặc "Out of Stock"

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.qty,
    required this.date,
    required this.status,
  });
}
