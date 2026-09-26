import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/world_map_dots.dart';

/// Indigo marketing panel with the dotted world map and a headline.
class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({
    super.key,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final String title;
  final String subtitle;

  /// Banner variant used above the form on tablets.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: AppColors.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              children: [
                // Map bleeds slightly past the top/right edges as in Figma.
                Positioned(
                  top: compact ? -height * 0.15 : -height * 0.02,
                  left: -width * 0.02,
                  width: width * 1.06,
                  child: const ExcludeSemantics(child: WorldMapDots()),
                ),
                Positioned(
                  left: compact ? 32 : width * 0.093,
                  right: compact ? 32 : width * 0.12,
                  bottom: compact ? 32 : height * 0.16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          title,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.white,
                            fontSize: compact ? 18 : 20,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          subtitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
