import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snackbar.dart';
import 'inline_link_text.dart';

/// "By clicking on … you agree to our privacy policy and terms of use".
class LegalNotice extends StatelessWidget {
  const LegalNotice({super.key, required this.actionLabel});

  /// Name of the submit button, e.g. "create account".
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    void comingSoon(String page) =>
        AppSnackbar.info(context, '$page will be available soon.');

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: InlineLinkText(
        segments: [
          TextSegment('By clicking on $actionLabel you agree to our '),
          TextSegment('privacy policy',
              onTap: () => comingSoon('Privacy policy')),
          const TextSegment(' and '),
          TextSegment('terms of use', onTap: () => comingSoon('Terms of use')),
        ],
      ),
    );
  }
}
