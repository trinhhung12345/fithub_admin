import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:fithub_admin/data/services/api_service.dart';
import 'package:fithub_admin/data/models/user_model.dart';

class UserService extends ApiService {
  // Get Current User Profile
  Future<UserModel?> getMe() async {
    try {
      final response = await dio.get('/users/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error getting profile: $e");
      rethrow;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    required DateTime birthday,
  }) async {
    try {
      final response = await dio.put(
        '/users/me',
        data: {
          "name": name,
          "phone": phone,
          "address": address,
          "birthday": DateFormat('yyyy-MM-dd').format(birthday),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error update profile: $e");
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await dio.put(
        '/users/me/password',
        data: {"oldPassword": oldPassword, "newPassword": newPassword},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      // In lỗi ra để debug nếu sai pass cũ
      print("Error change password: ${e.response?.data}");
      return false;
    }
  }
}
