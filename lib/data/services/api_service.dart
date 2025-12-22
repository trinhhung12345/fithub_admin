import 'package:dio/dio.dart';
import 'package:fithub_admin/configs/app_config.dart';
import 'package:fithub_admin/core/utils/token_manager.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Thêm Interceptor xử lý Bearer Token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Xử lý khi token hết hạn (ví dụ: bắt logout)
            print("Token expired or Unauthorized");
          }
          return handler.next(e);
        },
      ),
    );
  }
}
