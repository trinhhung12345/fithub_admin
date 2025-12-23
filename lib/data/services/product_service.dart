import 'package:fithub_admin/data/services/api_service.dart';
import 'package:fithub_admin/data/models/product_model.dart';
import 'package:fithub_admin/data/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:fithub_admin/data/models/product_tag.dart'; // Import Tag Model
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:flutter/foundation.dart'; // Để check kIsWeb
import 'package:http_parser/http_parser.dart'; // Để parse MediaType nếu cần

class ProductService extends ApiService {
  // 1. Get Products
  Future<List<ProductModel>> getProducts() async {
    try {
      // Gọi API: Token đã tự động được Interceptor thêm vào header
      final response = await dio.get('/products');

      // Parse dữ liệu: API trả về { "data": [...] }
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      rethrow;
    }
  }

  // 2. Get Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/categories');

      // Parse dữ liệu: API trả về trực tiếp [...] (Array)
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final response = await dio.get('/products/category/$categoryId');

      // API trả về trực tiếp List: [...]
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching products by category: $e");
      rethrow;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required List<ProductTag> tags,
    required List<XFile> images, // Dùng XFile của image_picker
  }) async {
    try {
      final formData = FormData();

      // 1. Add Text Fields
      formData.fields.addAll([
        MapEntry("name", name),
        MapEntry("description", description),
        MapEntry("price", price.toString()),
        MapEntry("stock", stock.toString()),
        MapEntry("categoryId", categoryId.toString()),
      ]);

      // 2. Add Tags (Cấu trúc: tags[0].name, tags[0].type)
      for (int i = 0; i < tags.length; i++) {
        formData.fields.add(MapEntry('tags[$i].name', tags[i].name));
        formData.fields.add(MapEntry('tags[$i].type', tags[i].typeName));
      }

      // 3. Add Files (Xử lý đa nền tảng)
      for (var file in images) {
        MultipartFile multipartFile;

        if (kIsWeb) {
          // WEB: Phải đọc bytes vì trình duyệt không cho truy cập path trực tiếp
          final bytes = await file.readAsBytes();
          multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
        } else {
          // MOBILE: Dùng path cho hiệu năng tốt hơn
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }

        formData.files.add(MapEntry("files", multipartFile));
      }

      // 4. Call API
      // Content-Type: multipart/form-data sẽ được Dio tự động thêm
      final response = await dio.post('/products', data: formData);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create product: $e");
      rethrow;
    }
  }
}
