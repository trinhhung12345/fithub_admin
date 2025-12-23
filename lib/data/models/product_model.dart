import 'package:fithub_admin/data/models/product_tag.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock; // Tương ứng QTY
  final int categoryId;
  final String categoryName;
  final String? imageUrl; // Logic lấy từ mảng files (ảnh đầu tiên)
  final List<String> fileUrls; // Danh sách tất cả ảnh
  final List<ProductTag> tags; // Danh sách tags
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
    this.fileUrls = const [],
    this.tags = const [],
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse List Files lấy URL
    List<String> urls = [];
    if (json['files'] != null && (json['files'] as List).isNotEmpty) {
      urls = (json['files'] as List)
          .map((f) => f['originUrl'] as String)
          .toList();
    }

    // 2. Parse Tags (MỚI)
    List<ProductTag> parsedTags = [];
    if (json['tags'] != null) {
      parsedTags = (json['tags'] as List).map((t) {
        // Map string từ server về Enum, nếu không khớp thì mặc định SHOES
        TagType type = TagType.values.firstWhere(
          (e) => e.name == (t['type'] as String).toUpperCase(),
          orElse: () => TagType.SHOES,
        );
        return ProductTag(name: t['name'], type: type);
      }).toList();
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
      fileUrls: urls, // Danh sách tất cả URL ảnh
      tags: parsedTags, // Gán tags
      imageUrl: urls.isNotEmpty ? urls.first : null, // Lấy ảnh đầu tiên
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
