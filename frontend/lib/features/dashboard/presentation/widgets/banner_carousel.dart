import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/dashboard_providers.dart';
import '../../data/models/dashboard_models.dart';
import 'common.dart';

/// Auto-advancing promo banner ("KEEP UP WITH YOUR BUSINESS NEEDS") with
/// page dots, fed by `GET /dashboard/banners`.
class BannerCarousel extends ConsumerWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = switch (context.screenSize) {
      ScreenSize.desktop => 243.0,
      ScreenSize.tablet => 200.0,
      ScreenSize.mobile => 160.0,
    };
    return ref.watch(bannersProvider).when(
          data: (slides) => slides.isEmpty
              ? const SizedBox.shrink()
              : _Carousel(slides: slides, height: height),
          loading: () => SkeletonBox(height: height + 20, radius: AppRadii.lg),
          error: (e, _) => SectionError(
            error: e,
            onRetry: () => ref.invalidate(bannersProvider),
          ),
        );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({required this.slides, required this.height});

  final List<BannerSlide> slides;
  final double height;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  static const _interval = Duration(seconds: 5);

  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) => _next());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (!_controller.hasClients || widget.slides.length < 2) return;
    _controller.animateToPage(
      (_index + 1) % widget.slides.length,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _goTo(int index) {
    _timer?.cancel();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _timer = Timer.periodic(_interval, (_) => _next());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _Slide(slide: widget.slides[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.slides.length; i++)
              GestureDetector(
                onTap: () => _goTo(i),
                child: Semantics(
                  label: 'Slide ${i + 1}',
                  selected: i == _index,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index ? AppColors.navy : AppColors.border,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final BannerSlide slide;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bannerStart, AppColors.bannerEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned(
                right: mobile ? 8 : 24,
                top: 8,
                bottom: 8,
                width: h * (mobile ? 1.0 : 1.2),
                child: _BannerIllustration(imageKey: slide.imageKey),
              ),
              Positioned(
                left: mobile ? 18 : 36,
                bottom: mobile ? 18 : 40,
                right: h * (mobile ? 1.0 : 1.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.title,
                      maxLines: 3,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: mobile ? 16 : 28,
                        height: 1.15,
                      ),
                    ),
                    if (slide.subtitle != null && !mobile) ...[
                      const SizedBox(height: 10),
                      Text(
                        slide.subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Banner artwork. Uses `assets/images/banner_<imageKey>.png` (exported from
/// Figma) and falls back to an icon composition if the file is missing.
class _BannerIllustration extends StatelessWidget {
  const _BannerIllustration({required this.imageKey});

  final String imageKey;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        'assets/images/banner_$imageKey.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        errorBuilder: (_, __, ___) => const _IllustrationFallback(),
      ),
    );
  }
}

class _IllustrationFallback extends StatelessWidget {
  const _IllustrationFallback();

  @override
  Widget build(BuildContext context) {
    const box = Color(0xFFD4A762);
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxHeight;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: s * 0.55,
                height: s * 0.55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFF5E6C8), Color(0xFFC89B5A)],
                    center: Alignment(-0.3, -0.3),
                  ),
                ),
                child: Icon(Icons.public,
                    size: s * 0.5, color: const Color(0xFF8C6A3A)),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.inventory_2, size: s * 0.34, color: box),
                  Icon(Icons.inventory_2,
                      size: s * 0.46, color: box.withOpacity(0.9)),
                  Icon(Icons.inventory_2, size: s * 0.3, color: box),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
