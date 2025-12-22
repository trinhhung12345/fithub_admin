import 'package:flutter/material.dart';
import 'package:fithub_admin/configs/app_colors.dart';

// Widget chung cho các màn hình rỗng
class BaseScreen extends StatelessWidget {
  final String title;
  const BaseScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tính năng đang phát triển...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Các màn hình cụ thể
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const BaseScreen(title: "Quản lý Sản phẩm");
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const BaseScreen(title: "Quản lý Danh mục");
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const BaseScreen(title: "Quản lý Đơn hàng");
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const BaseScreen(title: "Quản lý Người dùng");
}
