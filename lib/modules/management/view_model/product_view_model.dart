import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/product_model.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> products = [];
  List<CategoryModel> categories = [];

  // Quản lý Tabs
  List<String> tabs = ["All Product"]; // Mặc định có tab All
  int selectedTabIndex = 0;

  bool isLoading = false;
  String? errorMessage;

  // Init: Lấy tất cả sản phẩm và danh mục để dựng khung
  Future<void> initData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getProducts(),
        _service.getCategories(),
      ]);

      products = results[0] as List<ProductModel>;
      categories = results[1] as List<CategoryModel>;

      // Cập nhật lại Tabs: "All Product" + Tên các danh mục
      tabs = ["All Product", ...categories.map((e) => e.name)];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm xử lý khi bấm Tab
  Future<void> filterByCategory(int index) async {
    if (index == selectedTabIndex) return; // Bấm lại tab đang chọn thì bỏ qua

    selectedTabIndex = index;
    isLoading = true;
    notifyListeners();

    try {
      if (index == 0) {
        // Tab 0 là "All Product" -> Gọi API lấy tất cả
        products = await _service.getProducts();
      } else {
        // Các tab sau tương ứng với categories[index - 1]
        final categoryId = categories[index - 1].id;
        products = await _service.getProductsByCategory(categoryId);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
