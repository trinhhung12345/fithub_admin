import 'package:fithub_admin/data/services/api_service.dart';
import 'package:fithub_admin/data/models/category_model.dart';

class CategoryService extends ApiService {
  // Get All Categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await dio.get('/categories');

      if (response.statusCode == 200) {
        // API trả về trực tiếp mảng: [...]
        final List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      rethrow;
    }
  }
}
