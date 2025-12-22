import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Plus Jakarta Sans cho Headings
  static TextStyle headingStyle({
    double size = 24,
    FontWeight weight = FontWeight.bold,
    Color color = AppColors.textMain,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  // Manrope cho Body/Content
  static TextStyle bodyStyle({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = AppColors.textMain,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
