import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuItem {
  final String title;
  final String route;
  final IconData icon;

  MenuItem(this.title, this.route, this.icon);
}

class MenuConfig {
  static List<MenuItem> items = [
    MenuItem("Dashboard", "/dashboard", FontAwesomeIcons.chartPie),
    MenuItem("Sản phẩm", "/products", FontAwesomeIcons.boxOpen),
    MenuItem(
      "Danh mục",
      "/categories",
      FontAwesomeIcons.layerGroup,
    ), // Icon layer cho danh mục
    MenuItem(
      "Đơn hàng",
      "/orders",
      FontAwesomeIcons.fileInvoiceDollar,
    ), // Icon hóa đơn
  ];
}
