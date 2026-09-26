import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import 'auth_hero_panel.dart';

/// Split-screen auth scaffold from the design: form on the left, indigo
/// world-map panel on the right.
///
/// * ≥ 1024px: side-by-side (48% / 52%), as in Figma.
/// * 600–1023px: hero becomes a compact banner above the form.
/// * < 600px: form only, full width with 20px gutters.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.form,
    required this.heroTitle,
    required this.heroSubtitle,
  });

  final Widget form;
  final String heroTitle;
  final String heroSubtitle;

  /// Max width of the form column (≈ 535px in the 1440px Figma frame).
  static const double formMaxWidth = 540;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: switch (size) {
          ScreenSize.desktop => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 48, child: _FormPane(form: form, wide: true)),
                Expanded(
                  flex: 52,
                  child:
                      AuthHeroPanel(title: heroTitle, subtitle: heroSubtitle),
                ),
              ],
            ),
          ScreenSize.tablet => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 260,
                    child: AuthHeroPanel(
                      title: heroTitle,
                      subtitle: heroSubtitle,
                      compact: true,
                    ),
                  ),
                  _FormPane(form: form, wide: false, scrollable: false),
                ],
              ),
            ),
          ScreenSize.mobile => _FormPane(form: form, wide: false),
        },
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.form,
    required this.wide,
    this.scrollable = true,
  });

  final Widget form;
  final bool wide;

  /// False when a parent already scrolls (tablet layout).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return _content(const EdgeInsets.symmetric(horizontal: 32));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop: 100px left / 60px right at 1440px, scaled with the pane.
        final horizontal = wide
            ? EdgeInsets.only(
                left: math.min(100, constraints.maxWidth * 0.14),
                right: math.min(60, constraints.maxWidth * 0.08),
              )
            : const EdgeInsets.symmetric(horizontal: 20);

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: _content(horizontal)),
          ),
        );
      },
    );
  }

  Widget _content(EdgeInsets horizontal) => Padding(
        padding: horizontal.add(const EdgeInsets.symmetric(vertical: 40)),
        child: Align(
          alignment: wide ? Alignment.centerLeft : Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AuthLayout.formMaxWidth),
            child: form,
          ),
        ),
      );
}
