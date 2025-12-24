import 'package:flutter/material.dart';
import 'package:fithub_admin/data/models/user_model.dart';
import 'package:fithub_admin/data/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _service.getMe();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    required DateTime birthday,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final success = await _service.updateProfile(
        name: name,
        phone: phone,
        address: address,
        birthday: birthday,
      );

      if (success) {
        // Load lại data mới nhất từ server để đồng bộ UI
        await getProfile();
      }

      return success;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      // Lưu ý: getProfile đã set isLoading = false rồi,
      // nhưng nếu fail thì cần set lại ở đây
      if (isLoading) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    // Không cần set isLoading toàn cục để tránh rebuild cả màn hình Profile
    return await _service.changePassword(oldPass, newPass);
  }
}
