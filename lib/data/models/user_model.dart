class UserModel {
  final int id;
  final String code;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime? birthday;
  final String roleName;
  final String? avatarUrl; // Hiện tại null, sau này có thể map từ avatarId

  UserModel({
    required this.id,
    required this.code,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.birthday,
    required this.roleName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Xử lý Role Name
    String role = "User";
    if (json['role'] != null) {
      role = json['role']['roleName'] ?? "User";
    }

    return UserModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      roleName: role,
      avatarUrl: null, // Logic lấy ảnh từ avatarId nếu backend có API get file
    );
  }
}
