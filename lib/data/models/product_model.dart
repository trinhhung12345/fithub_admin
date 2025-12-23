class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock; // Tương ứng QTY
  final int categoryId;
  final String categoryName;
  final String? imageUrl; // Logic lấy từ mảng files
  // API hiện tại chưa thấy trả về Date, tạm thời để null hoặc placeholder
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Xử lý ảnh (Giữ nguyên logic cũ)
    String? img;
    if (json['files'] != null && (json['files'] as List).isNotEmpty) {
      // Check key originUrl (API get all) hoặc originUrl (API category)
      // JSON của bạn trả về giống nhau là originUrl nên ok
      img = json['files'][0]['originUrl'];
    }

    // XỬ LÝ CATEGORY (Logic mới)
    int catId = json['categoryId'] ?? 0;
    String catName = json['categoryName'] ?? '';

    // Nếu API trả về object "category" lồng bên trong (API filter by category)
    if (json['category'] != null) {
      catId = json['category']['id'] ?? 0;
      catName = json['category']['name'] ?? '';
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      categoryId: catId, // Dùng biến đã xử lý
      categoryName: catName, // Dùng biến đã xử lý
      imageUrl: img,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
