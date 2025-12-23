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

  // Sau này thêm hàm create/update/delete ở đây
}
