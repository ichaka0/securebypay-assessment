import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository.dart';
import '../data/models/dashboard_models.dart';
import '../data/models/shipment.dart';

/// Selected Overview period (dropdown).
final overviewPeriodProvider =
    StateProvider<OverviewPeriod>((_) => OverviewPeriod.month);

/// Selected chart range (Year / Month / Week toggle).
final growthRangeProvider = StateProvider<GrowthRange>((_) => GrowthRange.year);

final overviewProvider = FutureProvider.autoDispose<Overview>((ref) {
  final period = ref.watch(overviewPeriodProvider);
  return ref.watch(dashboardRepositoryProvider).overview(period);
});

final growthProvider = FutureProvider.autoDispose<List<GrowthPoint>>((ref) {
  final range = ref.watch(growthRangeProvider);
  return ref.watch(dashboardRepositoryProvider).growth(range);
});

final bannersProvider = FutureProvider.autoDispose<List<BannerSlide>>(
  (ref) => ref.watch(dashboardRepositoryProvider).banners(),
);

/// Recent shipments with "See All" pagination, plus pay/fund actions that
/// keep the list and the Overview balance in sync.
class RecentShipmentsController extends AutoDisposeAsyncNotifier<ShipmentPage> {
  static const pageSize = 3;

  DashboardRepository get _repo => ref.read(dashboardRepositoryProvider);

  @override
  Future<ShipmentPage> build() => _repo.shipments(limit: pageSize);

  /// Appends the next page ("See All" / "Load more").
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;
    final next = await _repo.shipments(page: current.page + 1, limit: pageSize);
    state = AsyncData(
      ShipmentPage(
        items: [...current.items, ...next.items],
        page: next.page,
        limit: next.limit,
        total: next.total,
      ),
    );
  }

  /// Throws `ApiException` (e.g. insufficient balance) for the UI to show.
  Future<void> pay(String shipmentId) async {
    final balance = await _repo.payShipment(shipmentId);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        ShipmentPage(
          items: [
            for (final s in current.items)
              s.id == shipmentId ? s.copyWith(isPaid: true) : s,
          ],
          page: current.page,
          limit: current.limit,
          total: current.total,
        ),
      );
    }
    ref.read(walletBalanceProvider.notifier).state = balance;
  }
}

final recentShipmentsProvider =
    AsyncNotifierProvider.autoDispose<RecentShipmentsController, ShipmentPage>(
  RecentShipmentsController.new,
);

/// Latest wallet balance returned by a pay/fund action. The balance card
/// prefers this over [overviewProvider]'s value, so the figure updates
/// instantly without refetching (and flashing) the whole Overview row.
final walletBalanceProvider = StateProvider.autoDispose<double?>((_) => null);

/// Credits the wallet (simulated payment) and publishes the new balance.
Future<void> fundWallet(WidgetRef ref, double amount) async {
  final balance =
      await ref.read(dashboardRepositoryProvider).fundWallet(amount);
  ref.read(walletBalanceProvider.notifier).state = balance;
}
