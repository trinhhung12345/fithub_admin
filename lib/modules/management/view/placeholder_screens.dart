import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Quản lý Sản phẩm', style: TextStyle(fontSize: 24)),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Quản lý Danh mục', style: TextStyle(fontSize: 24)),
    );
  }
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Quản lý Đơn hàng', style: TextStyle(fontSize: 24)),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Quản lý Khách hàng', style: TextStyle(fontSize: 24)),
    );
  }
}
