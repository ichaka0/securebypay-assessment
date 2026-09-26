import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/dashboard_models.dart';
import 'models/shipment.dart';

/// Dashboard, shipment and wallet endpoints.
class DashboardRepository {
  DashboardRepository(this._api);

  final ApiClient _api;

  Future<Overview> overview(OverviewPeriod period) async => Overview.fromJson(
        await _api
            .get('/dashboard/overview', query: {'period': period.apiValue}),
      );

  Future<List<GrowthPoint>> growth(GrowthRange range) async {
    final json =
        await _api.get('/dashboard/growth', query: {'range': range.apiValue});
    return (json['points'] as List)
        .map((e) => GrowthPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BannerSlide>> banners() async =>
      (await _api.getList('/dashboard/banners'))
          .map((e) => BannerSlide.fromJson(e as Map<String, dynamic>))
          .toList();

  Future<ShipmentPage> shipments({int page = 1, int limit = 3}) async =>
      ShipmentPage.fromJson(
        await _api.get('/shipments', query: {'page': page, 'limit': limit}),
      );

  /// Pays for a shipment from the wallet; returns the new wallet balance.
  Future<double> payShipment(String id) async {
    final json = await _api.post('/shipments/$id/pay');
    return (json['walletBalance'] as num).toDouble();
  }

  /// Credits the wallet; returns the new balance.
  Future<double> fundWallet(double amount) async {
    final json = await _api.post('/wallet/fund', body: {'amount': amount});
    return (json['walletBalance'] as num).toDouble();
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);
