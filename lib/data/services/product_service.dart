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
    required List<XFile> images,
  }) async {
    try {
      final formData = FormData();

      // 1. Add Text Fields
      formData.fields.addAll([
        MapEntry("name", name),
        MapEntry("description", description),
        MapEntry("price", price.toStringAsFixed(0)),
        MapEntry("stock", stock.toString()),
        MapEntry("categoryId", categoryId.toString()),
      ]);

      // 2. Add Tags
      for (int i = 0; i < tags.length; i++) {
        formData.fields.add(MapEntry('tags[$i].name', tags[i].name));
        formData.fields.add(MapEntry('tags[$i].type', tags[i].typeName));
      }

      // 3. Add Files
      for (var file in images) {
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
        } else {
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }
        formData.files.add(MapEntry("files", multipartFile));
      }

      // --- 👇 DEBUG LOG: IN RA MỌI THỨ SẮP GỬI ĐI 👇 ---
      print('================= 🚀 DEBUG REQUEST BODY 🚀 =================');
      print('URL: ${dio.options.baseUrl}/products');
      print('FIELDS:');
      for (var field in formData.fields) {
        print('   👉 ${field.key}: ${field.value}');
      }

      print('FILES:');
      for (var file in formData.files) {
        print(
          '   📁 Key: ${file.key} | Filename: ${file.value.filename} | Size: ${file.value.length} bytes',
        );
      }
      print('==========================================================');
      // -----------------------------------------------------------

      // 4. Call API
      final response = await dio.post(
        '/products',
        data: formData,
        options: Options(sendTimeout: const Duration(seconds: 60)),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("❌ DIO ERROR: ${e.message}");
      print("❌ STATUS: ${e.response?.statusCode}");
      print(
        "❌ SERVER MSG: ${e.response?.data}",
      ); // Đây là chỗ hiện "Product name exist"
      rethrow;
    } catch (e) {
      print("❌ UNKNOWN ERROR: $e");
      rethrow;
    }
  }

  Future<ProductModel?> getProductDetail(int id) async {
    try {
      final response = await dio.get('/products/$id');

      if (response.statusCode == 200) {
        // API trả về: { "data": { ... } }
        return ProductModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error get product detail: $e");
      rethrow;
    }
  }

  // 5. Update Product (PUT)
  Future<bool> updateProduct({
    required int id, // ID sản phẩm cần sửa
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required List<ProductTag> tags,
    required List<XFile> newImages, // Chỉ gửi ảnh MỚI thêm vào
  }) async {
    try {
      final formData = FormData();

      // 1. Add ID (Quan trọng nhất)
      formData.fields.add(MapEntry("id", id.toString()));

      // 2. Add các field cơ bản
      formData.fields.addAll([
        MapEntry("name", name),
        MapEntry("description", description),
        MapEntry("price", price.toStringAsFixed(0)),
        MapEntry("stock", stock.toString()),
        MapEntry("categoryId", categoryId.toString()),
      ]);

      // 3. Add Tags
      for (int i = 0; i < tags.length; i++) {
        formData.fields.add(MapEntry('tags[$i].name', tags[i].name));
        formData.fields.add(MapEntry('tags[$i].type', tags[i].typeName));
      }

      // 4. Add Files MỚI (Server sẽ xử lý thêm vào hoặc thay thế tùy logic backend)
      for (var file in newImages) {
        MultipartFile multipartFile;
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
        } else {
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }
        formData.files.add(MapEntry("files", multipartFile));
      }

      print("DEBUG: Sending PUT request to /products with ID: $id");

      final response = await dio.put(
        // Dùng PUT
        '/products',
        data: formData,
        options: Options(sendTimeout: const Duration(seconds: 60)),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print("❌ UPDATE ERROR: ${e.response?.data}");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 6. Delete Product
  Future<bool> deleteProduct(int id) async {
    try {
      print("DEBUG: Deleting product $id...");
      final response = await dio.delete('/products/$id');

      // API trả về code 200 là thành công
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting product: $e");
      // Nếu API trả về lỗi (ví dụ sản phẩm đang có đơn hàng không xóa được), bạn có thể catch để báo lỗi
      return false;
    }
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      // Gọi API: /products/search?keyword=abc
      final response = await dio.get(
        '/products/search',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error searching products: $e");
      rethrow;
    }
  }
}
