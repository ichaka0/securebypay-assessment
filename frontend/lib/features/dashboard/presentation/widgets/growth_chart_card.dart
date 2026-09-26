import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/dashboard_providers.dart';
import '../../data/models/dashboard_models.dart';
import 'common.dart';

/// "Company Growth" line chart with the Year / Month / Week toggle.
/// Values are total shipment value (₦) per bucket from `/dashboard/growth`.
class GrowthChartCard extends ConsumerWidget {
  const GrowthChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(growthRangeProvider);
    final growth = ref.watch(growthProvider);
    final chartHeight = context.isMobile ? 200.0 : 260.0;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Text(
                'Company Growth',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _RangeToggle(
                value: range,
                onChanged: (r) =>
                    ref.read(growthRangeProvider.notifier).state = r,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: chartHeight,
            child: growth.when(
              skipLoadingOnReload: true,
              data: (points) => _LineChart(points: points, range: range),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              error: (e, _) => SectionError(
                error: e,
                onRetry: () => ref.invalidate(growthProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.points, required this.range});

  final List<GrowthPoint> points;
  final GrowthRange range;

  /// Rounds the max value up to a "nice" axis limit (1, 2, 2.5, 5 × 10ⁿ).
  static double _niceMax(double value) {
    if (value <= 0) return 1000;
    final exponent = math.pow(10, (math.log(value) / math.ln10).floor());
    for (final step in [1, 2, 2.5, 5, 10]) {
      final candidate = step * exponent;
      if (candidate >= value) return candidate.toDouble();
    }
    return 10.0 * exponent;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(0, (m, p) => math.max(m, p.value));
    final maxY = _niceMax(maxValue * 1.1);
    final interval = maxY / 5;
    final labelEvery = switch (range) {
      GrowthRange.year => context.isMobile ? 2 : 1,
      GrowthRange.month => 5,
      GrowthRange.week => 1,
    };

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.borderLight,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child:
                    Text(Formatters.compact(value), style: AppTextStyles.tiny),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i != value || i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                final isLast = i == points.length - 1;
                if (i % labelEvery != 0 && !isLast) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(points[i].label, style: AppTextStyles.tiny),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.navy,
            tooltipRoundedRadius: AppRadii.md,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  '${points[spot.x.toInt()].label}\n',
                  AppTextStyles.tiny
                      .copyWith(color: AppColors.white.withOpacity(0.8)),
                  children: [
                    TextSpan(
                      text: Formatters.currencyWhole(spot.y),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.22),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// Segmented "Year | Month | Week" control on a grey track.
class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.value, required this.onChanged});

  final GrowthRange value;
  final ValueChanged<GrowthRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in GrowthRange.values)
            Semantics(
              button: true,
              selected: r == value,
              child: InkWell(
                onTap: () => onChanged(r),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: r == value ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    boxShadow: r == value
                        ? const [
                            BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 2,
                                offset: Offset(0, 1))
                          ]
                        : null,
                  ),
                  child: Text(
                    r.label,
                    style: AppTextStyles.tiny.copyWith(
                      color: r == value
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight:
                          r == value ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
