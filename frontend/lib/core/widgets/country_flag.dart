import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small rectangular flag for an ISO 3166-1 alpha-2 [countryCode].
///
/// Drawn with plain widgets so it renders identically on every browser
/// (emoji flags are not supported on Windows). Countries without a simple
/// tri-band definition fall back to a neutral chip with the code.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.countryCode, this.width = 14});

  final String countryCode;
  final double width;

  static const _verticalBands = <String, List<Color>>{
    'NG': [Color(0xFF008751), Colors.white, Color(0xFF008751)],
    'CA': [Color(0xFFD80621), Colors.white, Color(0xFFD80621)],
  };
  static const _horizontalBands = <String, List<Color>>{
    'GH': [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF006B3F)],
    'GB': [Color(0xFF012169), Color(0xFFC8102E), Color(0xFF012169)],
    'US': [Color(0xFFB22234), Colors.white, Color(0xFF3C3B6E)],
  };

  @override
  Widget build(BuildContext context) {
    final height = width * 0.7;
    final code = countryCode.toUpperCase();
    final vertical = _verticalBands[code];
    final horizontal = _horizontalBands[code];

    Widget child;
    if (vertical != null) {
      child = Row(children: [
        for (final c in vertical) Expanded(child: ColoredBox(color: c))
      ]);
    } else if (horizontal != null) {
      child = Column(children: [
        for (final c in horizontal) Expanded(child: ColoredBox(color: c))
      ]);
    } else {
      child = ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child:
              FittedBox(child: Text(code, style: const TextStyle(fontSize: 8))),
        ),
      );
    }

    return Semantics(
      label: 'Flag of $code',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.5),
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}
