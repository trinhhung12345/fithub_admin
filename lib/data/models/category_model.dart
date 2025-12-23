class CategoryModel {
  final int id;
  final String name;
  final String description;
  final bool active; // Thêm trường này

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.active = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? true, // Mặc định true nếu null
    );
  }
}
