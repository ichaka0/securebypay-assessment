import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum SnackType { success, error, info }

/// Consistent success/error/info toasts, shown at the top of the screen.
///
/// Toasts live in the root [Overlay] (owned by the app's Navigator), so a
/// toast raised just before a route change, e.g. "Account created" before
/// the redirect to the dashboard, stays visible on the next page.
/// Only one toast is shown at a time; a new one replaces the current one.
abstract final class AppSnackbar {
  static const _displayDuration = Duration(seconds: 4);

  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _removeCurrent();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastHost(
        message: message,
        type: type,
        duration: _displayDuration,
        onDismissed: () {
          if (_current == entry) _removeCurrent();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackType.info);

  static void _removeCurrent() {
    _current?.remove();
    _current = null;
  }
}

/// Animates a toast in from the top, auto-dismisses it after [duration],
/// and lets the user close it early.
class _ToastHost extends StatefulWidget {
  const _ToastHost({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.6),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (widget.type) {
      SnackType.success => (AppColors.success, Icons.check_circle_outline),
      SnackType.error => (AppColors.error, Icons.error_outline),
      SnackType.info => (AppColors.navy, Icons.info_outline),
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _controller,
                  child: Semantics(
                    liveRegion: true,
                    child: Material(
                      color: color,
                      elevation: 6,
                      shadowColor: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                        child: Row(
                          children: [
                            Icon(icon, color: AppColors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Dismiss',
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              color: AppColors.white,
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _dismiss,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
