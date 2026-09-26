import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../application/dashboard_providers.dart';
import 'common.dart';
import 'growth_chart_card.dart';
import 'shipment_card.dart';

/// "Recent shipment": growth chart followed by the latest shipment cards,
/// with "See All" loading further pages.
class RecentShipmentsSection extends ConsumerStatefulWidget {
  const RecentShipmentsSection({super.key});

  @override
  ConsumerState<RecentShipmentsSection> createState() =>
      _RecentShipmentsSectionState();
}

class _RecentShipmentsSectionState
    extends ConsumerState<RecentShipmentsSection> {
  bool _loadingMore = false;

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await ref.read(recentShipmentsProvider.notifier).loadMore();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _pay(String id) async {
    try {
      await ref.read(recentShipmentsProvider.notifier).pay(id);
      if (mounted) AppSnackbar.success(context, 'Payment successful.');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipments = ref.watch(recentShipmentsProvider);
    final hasMore = shipments.valueOrNull?.hasMore ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Recent shipment',
          trailing: PillButton(
            label: 'See All',
            onPressed: hasMore && !_loadingMore ? _loadMore : null,
          ),
        ),
        const SizedBox(height: 12),
        const GrowthChartCard(),
        const SizedBox(height: 16),
        shipments.when(
          data: (page) {
            if (page.items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No shipments yet.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, s) in page.items.indexed) ...[
                  if (i > 0) const SizedBox(height: 12),
                  ShipmentCard(
                    key: ValueKey(s.id),
                    shipment: s,
                    onPay: () => _pay(s.id),
                  ),
                ],
                if (hasMore) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: _loadingMore
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: _loadMore,
                            child: const Text('Load more'),
                          ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Column(
            children: [
              SkeletonBox(height: 140),
              SizedBox(height: 12),
              SkeletonBox(height: 140),
            ],
          ),
          error: (e, _) => SectionError(
            error: e,
            onRetry: () => ref.invalidate(recentShipmentsProvider),
          ),
        ),
      ],
    );
  }
}
