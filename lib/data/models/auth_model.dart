class LoginResponse {
  final String? accessToken;
  final String? message;
  final Map<String, dynamic>?
  userInfo; // Lưu thêm thông tin user (tên, role...)

  LoginResponse({this.accessToken, this.message, this.userInfo});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // 1. Lấy object 'data' từ JSON gốc
    final data = json['data'] as Map<String, dynamic>?;

    return LoginResponse(
      // 2. Lấy accessToken từ trong 'data'
      accessToken: data?['accessToken'],

      // 3. Lấy message từ bên ngoài
      message: json['message'],

      // 4. Lưu lại toàn bộ cục data để dùng sau (lấy tên, avatar...)
      userInfo: data,
    );
  }
}
