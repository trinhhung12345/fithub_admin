import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:fithub_admin/data/services/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> initData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await _service.getAllCategories();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required String description,
    required int status,
  }) async {
    // Không set isLoading toàn cục ở đây để tránh bảng bị loading lại,
    // Loading sẽ hiển thị cục bộ trên nút Save của Dialog
    final success = await _service.createCategory(
      name: name,
      description: description,
      status: status,
    );

    if (success) {
      // Nếu thành công, reload lại danh sách để hiện item mới
      await initData();
    }

    return success;
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool status,
  }) async {
    final success = await _service.updateCategory(
      id: id,
      name: name,
      description: description,
      status: status,
    );

    if (success) {
      // Reload lại danh sách để thấy thay đổi
      await initData();
    }

    return success;
  }

  Future<bool> deleteCategory(int id) async {
    final success = await _service.deleteCategory(id);

    if (success) {
      // Xóa item khỏi list hiện tại để không phải load lại API
      categories.removeWhere((item) => item.id == id);
      notifyListeners();
    }

    return success;
  }
}
