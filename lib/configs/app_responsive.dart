import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget web;

  const Responsive({super.key, required this.mobile, required this.web});

  // Quy ước: Dưới 850 pixel là Mobile/Tablet dọc, trên đó là Web/Tablet ngang
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 850) {
          return web;
        }
        return mobile;
      },
    );
  }
}
