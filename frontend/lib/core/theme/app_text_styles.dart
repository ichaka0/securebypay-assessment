import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale used across the app.
abstract final class AppTextStyles {
  /// Bundled font family (see pubspec.yaml).
  static const fontFamily = 'Inter';

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Page titles, e.g. "Create an account".
  static TextStyle get heading => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// Section titles, e.g. "Overview", "Recent shipment".
  static TextStyle get title => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get subtitle => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => _base.copyWith(fontSize: 14);

  static TextStyle get bodySecondary =>
      body.copyWith(color: AppColors.textSecondary, fontSize: 13);

  static TextStyle get label => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get tiny => _base.copyWith(
        fontSize: 11,
        color: AppColors.textMuted,
      );

  static TextStyle get link => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );

  static TextStyle get button => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      );

  /// Large figures in stat cards.
  static TextStyle get metric => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
