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

  Future<bool> createCategory({
    required String name,
    required String description,
    required int status, // 1: Active, 0: Inactive
  }) async {
    try {
      final response = await dio.post(
        '/categories',
        data: {"name": name, "description": description, "status": status},
      );

      // API trả về Object json của Category vừa tạo -> Thành công
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating category: $e");
      // Bạn có thể catch DioException để lấy message lỗi chi tiết giống bên Product
      return false;
    }
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required String description,
    required bool status, // API yêu cầu bool (true/false)
  }) async {
    try {
      final response = await dio.put(
        '/categories/$id', // ID trên URL
        data: {
          "name": name,
          "description": description,
          "status": status, // Gửi boolean
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await dio.delete('/categories/$id');

      // API trả về 204 No Content -> Thành công
      // Một số backend có thể trả về 200, nên check cả hai cho chắc
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }
}
