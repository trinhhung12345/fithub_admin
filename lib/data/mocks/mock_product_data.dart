import 'package:fithub_admin/data/models/product_model.dart';

class MockProductData {
  static List<ProductModel> get products {
    return List.generate(15, (index) {
      final isAvailable = index % 2 == 0;
      return ProductModel(
        id: "02123${index + 1}",
        name: isAvailable
            ? "Kanky Kitadakate (Green) - $index"
            : "Story Honzo (Cream) - $index",
        image: "https://via.placeholder.com/150", // Ảnh giả placeholder
        price: 32.032 + (index * 10),
        size: 40 + (index % 5),
        qty: 100 + (index * 20),
        date: DateTime.now().subtract(Duration(days: index)),
        status: isAvailable ? "Available" : "Out of Stock",
      );
    });
  }
}
