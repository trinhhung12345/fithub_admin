import 'package:fithub_admin/data/models/auth_model.dart';
import 'api_service.dart';

class AuthService extends ApiService {
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
