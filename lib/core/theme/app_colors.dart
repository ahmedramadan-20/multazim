import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // indigo
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color accent = Color(0xFF7C3AED); // purple

  // Semantic
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  // Habit status colors
  static const Color completed = Color(0xFF059669); // ✅
  static const Color skipped = Color(0xFFD97706); // ⏭
  static const Color failed = Color(0xFFDC2626); // ❌
  static const Color pending = Color(0xFF9CA3AF); // ⬜

  // StrictnessLevel colors
  static const Color strictnessLow = Color(0xFF059669); // 🟢
  static const Color strictnessMedium = Color(0xFFD97706); // 🟡
  static const Color strictnessHigh = Color(0xFFDC2626); // 🔴

  // Neutral
  static const Color dark = Color(0xFF1E1B4B);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  // Heatmap (for analytics — Phase 3)
  static const List<Color> heatmap = [
    Color(0xFFEEF2FF), // 0% — empty
    Color(0xFFC7D2FE), // 1–25%
    Color(0xFF818CF8), // 26–50%
    Color(0xFF4F46E5), // 51–75%
    Color(0xFF1E1B4B), // 76–100% — full
  ];
}
