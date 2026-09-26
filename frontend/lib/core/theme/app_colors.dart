import 'package:flutter/material.dart';

/// Colour tokens taken from the Figma design.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF5D60AE);
  static const primaryDark = Color(0xFF4B4E99);
  static const navy = Color(0xFF2E3070);
  static const bannerStart = Color(0xFF22245A);
  static const bannerEnd = Color(0xFF34377E);

  // Neutrals
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFFFFFFF);
  static const sidebar = Color(0xFFF7F7F9);
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFEEEFF3);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const placeholder = Color(0xFFB0B5BF);

  // Feedback
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF97316);
  static const warningBg = Color(0xFFFFEDD5);
  static const info = Color(0xFF0891B2);
  static const infoBg = Color(0xFFCFFAFE);
  static const importBlue = Color(0xFF3B82F6);
  static const importBlueBg = Color(0xFFDBEAFE);
}
