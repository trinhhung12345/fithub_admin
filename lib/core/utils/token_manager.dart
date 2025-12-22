import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = "access_token";

  // Lưu token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Giải mã lấy UserId
  static Map<String, dynamic>? decodeToken(String token) {
    if (JwtDecoder.isExpired(token)) return null;
    return JwtDecoder.decode(token);
  }

  // Kiểm tra token còn hạn không
  static bool isTokenValid(String token) {
    return !JwtDecoder.isExpired(token);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
