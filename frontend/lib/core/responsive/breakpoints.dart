import 'package:flutter/widgets.dart';

/// Layout breakpoints (logical pixels).
///
/// * mobile  : < 600
/// * tablet  : 600 – 1023
/// * desktop : ≥ 1024
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

enum ScreenSize { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final width = screenWidth;
    if (width >= Breakpoints.desktop) return ScreenSize.desktop;
    if (width >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isDesktop => screenSize == ScreenSize.desktop;
}
