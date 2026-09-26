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
import 'fund_wallet_dialog.dart';

/// "Overview" row: wallet balance card + three shipment stat cards.
///
/// Desktop: one row (≈ 44/21/21/21 split as in Figma).
/// Tablet: balance on its own row, stats in a row below.
/// Mobile: balance, then stats in a 2-column grid.
class OverviewSection extends ConsumerWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(overviewPeriodProvider);
    final overview = ref.watch(overviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Overview',
          trailing: _PeriodDropdown(
            value: period,
            onChanged: (p) =>
                ref.read(overviewPeriodProvider.notifier).state = p,
          ),
        ),
        const SizedBox(height: 12),
        overview.when(
          skipLoadingOnReload: true,
          data: (data) => _Cards(overview: data, period: period),
          loading: () => const SkeletonBox(height: 162),
          error: (e, _) => SectionError(
            error: e,
            onRetry: () => ref.invalidate(overviewProvider),
          ),
        ),
      ],
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards({required this.overview, required this.period});

  final Overview overview;
  final OverviewPeriod period;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCard(
        title: 'Total Shipment',
        icon: Icons.inventory_2_outlined,
        iconColor: AppColors.warning,
        iconBackground: AppColors.warningBg,
        stat: overview.totalShipments,
        caption: period.comparisonLabel,
      ),
      _StatCard(
        title: 'Total Exports',
        icon: Icons.arrow_upward_rounded,
        iconColor: AppColors.success,
        iconBackground: AppColors.successBg,
        stat: overview.totalExports,
        caption: period.comparisonLabel,
      ),
      _StatCard(
        title: 'Total Import',
        icon: Icons.arrow_downward_rounded,
        iconColor: AppColors.importBlue,
        iconBackground: AppColors.importBlueBg,
        stat: overview.totalImports,
        caption: period.comparisonLabel,
      ),
    ];
    final balance = _BalanceCard(fallbackBalance: overview.walletBalance);
    const gap = 16.0;

    switch (context.screenSize) {
      case ScreenSize.desktop:
        return SizedBox(
          height: 162,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 44, child: balance),
              for (final card in stats) ...[
                const SizedBox(width: gap),
                Expanded(flex: 21, child: card),
              ],
            ],
          ),
        );
      case ScreenSize.tablet:
        return Column(
          children: [
            SizedBox(height: 150, child: balance),
            const SizedBox(height: gap),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    Expanded(child: stats[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      case ScreenSize.mobile:
        return LayoutBuilder(
          builder: (context, constraints) {
            final half = (constraints.maxWidth - 12) / 2;
            return Column(
              children: [
                SizedBox(height: 150, child: balance),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final card in stats)
                      SizedBox(width: half, height: 130, child: card),
                  ],
                ),
              ],
            );
          },
        );
    }
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.fallbackBalance});

  final double fallbackBalance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider) ?? fallbackBalance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Balance',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.currency(balance),
              style: AppTextStyles.metric.copyWith(color: AppColors.white),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () => showFundWalletDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 30),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                textStyle: AppTextStyles.tiny.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Fund Wallet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.stat,
    required this.caption,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Stat stat;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final up = stat.changePercent >= 0;
    final changeColor = up ? AppColors.success : AppColors.error;
    return DashboardCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${stat.value}', style: AppTextStyles.metric),
              const SizedBox(width: 6),
              Icon(
                up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: changeColor,
              ),
              Text(
                '${stat.changePercent.abs()}%',
                style: AppTextStyles.tiny.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(caption, style: AppTextStyles.tiny),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({required this.value, required this.onChanged});

  final OverviewPeriod value;
  final ValueChanged<OverviewPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OverviewPeriod>(
      tooltip: 'Select period',
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      itemBuilder: (_) => [
        for (final p in OverviewPeriod.values)
          PopupMenuItem(
            value: p,
            height: 36,
            child: Text(p.label, style: AppTextStyles.caption),
          ),
      ],
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value.label,
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.textSecondary,
                )),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
