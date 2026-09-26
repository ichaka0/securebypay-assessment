import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

/// A text segment inside [InlineLinkText]; tappable when [onTap] is set.
class TextSegment {
  const TextSegment(this.text, {this.onTap});

  final String text;
  final VoidCallback? onTap;
}

/// Paragraph mixing plain text and underlined links, e.g.
/// "Do you already have an account? **Login**".
///
/// Links are rendered as [WidgetSpan]s with their own [InkWell], which avoids
/// managing `TapGestureRecognizer` lifecycles and gives a proper hover cursor.
class InlineLinkText extends StatelessWidget {
  const InlineLinkText({super.key, required this.segments, this.style});

  final List<TextSegment> segments;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTextStyles.caption.copyWith(height: 1.6);
    final linkStyle = AppTextStyles.link.copyWith(
      fontSize: base.fontSize,
      height: base.height,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final segment in segments)
            if (segment.onTap == null)
              TextSpan(text: segment.text)
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Semantics(
                  link: true,
                  child: InkWell(
                    onTap: segment.onTap,
                    borderRadius: BorderRadius.circular(2),
                    child: Text(segment.text, style: linkStyle),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
