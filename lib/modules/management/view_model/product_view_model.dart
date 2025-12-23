import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/models/product_model.dart';
import 'package:fithub_admin/data/services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _sourceProducts = []; // Danh sách gốc
  List<ProductModel> products = []; // Danh sách hiển thị

  List<CategoryModel> categories = [];
  List<String> tabs = ["All Product"];
  int selectedTabIndex = 0;

  bool isLoading = false;
  String? errorMessage;

  // --- 🆕 LOGIC SELECTION (THÊM MỚI) ---
  Set<int> selectedIds = {}; // Dùng Set để lưu ID các sản phẩm đang chọn

  // 1. Chọn/Bỏ chọn 1 sản phẩm
  void toggleProductSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  // 2. Chọn/Bỏ chọn tất cả (Dựa trên danh sách đang hiển thị)
  void toggleSelectAll(bool isSelected) {
    if (isSelected) {
      // Chỉ chọn những thằng đang hiện ra (products), không chọn thằng bị ẩn do filter
      selectedIds = products.map((e) => e.id).toSet();
    } else {
      selectedIds.clear();
    }
    notifyListeners();
  }
  // -------------------------------------

  // --- INIT DATA ---
  Future<void> initData() async {
    isLoading = true;
    selectedIds.clear(); // Reset selection khi reload
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getProducts(),
        _service.getCategories(),
      ]);
      _sourceProducts = results[0] as List<ProductModel>;
      products = List.from(_sourceProducts);
      categories = results[1] as List<CategoryModel>;
      tabs = ["All Product", ...categories.map((e) => e.name)];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- FILTER ---
  Future<void> filterByCategory(int index) async {
    if (index == selectedTabIndex) return;
    selectedTabIndex = index;
    isLoading = true;
    selectedIds.clear(); // Reset selection khi đổi tab
    notifyListeners();
    try {
      if (index == 0) {
        _sourceProducts = await _service.getProducts();
      } else {
        final categoryId = categories[index - 1].id;
        _sourceProducts = await _service.getProductsByCategory(categoryId);
      }
      products = List.from(_sourceProducts);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- SEARCH ---
  void searchProduct(String query) {
    selectedIds.clear(); // Reset selection khi search
    if (query.isEmpty) {
      products = List.from(_sourceProducts);
    } else {
      final lowerQuery = query.toLowerCase();
      products = _sourceProducts.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.id.toString().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  // --- DELETE SINGLE (Cập nhật) ---
  Future<bool> deleteProduct(int id) async {
    try {
      final success = await _service.deleteProduct(id);
      if (success) {
        _sourceProducts.removeWhere((p) => p.id == id);
        products.removeWhere((p) => p.id == id);
        selectedIds.remove(id); // Xóa khỏi danh sách chọn nếu có
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  // --- 🆕 DELETE BULK (XÓA NHIỀU) ---
  Future<bool> deleteSelectedProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Tạo danh sách các Future để gọi API song song
      final List<Future<bool>> deleteFutures = [];
      for (var id in selectedIds) {
        deleteFutures.add(_service.deleteProduct(id));
      }

      // 2. Chờ tất cả chạy xong
      final results = await Future.wait(deleteFutures);

      // 3. Kiểm tra kết quả (Nếu tất cả đều true là thành công trọn vẹn)
      // Thực tế: Có thể có cái xóa được, cái lỗi.
      // Ở đây ta sẽ lọc những cái xóa thành công để update UI.

      // Chuyển Set thành List để duyệt index khớp với results
      final idsList = selectedIds.toList();
      final deletedIds = <int>[];

      for (int i = 0; i < results.length; i++) {
        if (results[i] == true) {
          deletedIds.add(idsList[i]);
        }
      }

      // 4. Update UI Local
      _sourceProducts.removeWhere((p) => deletedIds.contains(p.id));
      products.removeWhere((p) => deletedIds.contains(p.id));
      selectedIds.clear(); // Xóa xong thì bỏ chọn hết

      // Trả về true nếu không có cái nào lỗi
      return !results.contains(false);
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
