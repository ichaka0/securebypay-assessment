import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Filled brand button that shows a spinner and blocks taps while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Stretch to the parent's width (used on mobile).
  final bool expand;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: backgroundColor == null
          ? null
          : ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: loading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(label, key: const ValueKey('label')),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
