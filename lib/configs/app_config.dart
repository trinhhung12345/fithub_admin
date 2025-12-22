class AppConfig {
  // Base URL kết nối đến Backend Spring Boot qua Tailscale
  static const String baseUrl = 'http://100.127.71.42:6868/api/v1';

  // Bạn có thể thêm các cấu hình thời gian timeout tại đây
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Sau này nếu có các môi trường khác (Production, Stage)
  // bạn chỉ cần sửa giá trị ở đây là toàn bộ App sẽ thay đổi theo.
}
