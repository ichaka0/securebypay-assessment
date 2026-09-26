import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/auth/data/models/user.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user = User(
  id: 'u1',
  firstName: 'Jane',
  lastName: 'Doe',
  email: 'jane@example.com',
  phoneNumber: '+2349012345678',
  walletBalance: 3000000.28,
);

Map<String, dynamic> _shipment(String id, {required bool paid}) => {
      'id': id,
      'trackingId': 'MAF-100-234-29$id',
      'sender': 'Bunmi Tanny',
      'receiver': 'Mercy',
      'pickupFrom': 'Lagos, Nigeria',
      'pickupCountry': 'NG',
      'deliveryTo': 'Oyo Nigeria',
      'deliveryCountry': 'NG',
      'amount': 3000,
      'status': paid ? 'in_transit' : 'delayed',
      'type': 'export',
      'processingHours': 10,
      'isPaid': paid,
      'shippedAt': '2026-09-25T10:00:00.000Z',
    };

/// Serves canned dashboard responses by path.
class _FakeApi implements HttpClientAdapter {
  static final _responses = <String, Object>{
    '/api/dashboard/banners': [
      {
        'id': 'b1',
        'title': 'KEEP UP WITH YOUR BUSINESS NEEDS',
        'imageKey': 'globe_boxes'
      },
    ],
    '/api/dashboard/overview': {
      'period': 'month',
      'walletBalance': 3000000.28,
      'totalShipments': {'value': 34, 'changePercent': 10},
      'totalExports': {'value': 34, 'changePercent': 10},
      'totalImports': {'value': 34, 'changePercent': -5},
    },
    '/api/dashboard/growth': {
      'range': 'year',
      'points': [
        for (var i = 0; i < 12; i++)
          {'label': 'M$i', 'value': (i * 80) % 700 + 100},
      ],
    },
    '/api/shipments': {
      'items': [_shipment('1', paid: true), _shipment('2', paid: false)],
      'page': 1,
      'limit': 3,
      'total': 2,
    },
  };

  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<List<int>>? _, Future<void>? __) async {
    final body = _responses[options.uri.path];
    return ResponseBody.fromString(
      jsonEncode(body ?? {'message': 'not found'}),
      body == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SignedIn extends AuthController {
  int signOutCalls = 0;

  @override
  Future<User?> build() async => _user;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    state = const AsyncData(null);
  }
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Size size,
  AuthController Function()? auth,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
    ..httpClientAdapter = _FakeApi();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(
          ApiClient(tokenStorage: TokenStorage(prefs), dio: dio),
        ),
        authControllerProvider.overrideWith(auth ?? _SignedIn.new),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const DashboardPage()),
    ),
  );
  // Let requests resolve; avoid pumpAndSettle because the carousel timer
  // and chart animations keep scheduling frames.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  const sizes = {
    'mobile': Size(390, 844),
    'tablet': Size(768, 1024),
    'desktop': Size(1440, 1024),
  };

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('Dashboard renders without overflow on $name', (tester) async {
      await _pumpDashboard(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('₦3,000,000.28'), findsOneWidget);
      expect(find.text('Company Growth'), findsOneWidget);
      expect(find.text('Pay Now'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);

      // Unmount so the carousel timer is cancelled before the test ends.
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Logout asks for confirmation before signing out',
      (tester) async {
    final auth = _SignedIn();
    await _pumpDashboard(tester,
        size: const Size(1440, 1024), auth: () => auth);

    // "No" keeps the user signed in.
    await tester.tap(find.text('Logout'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Are you sure you want to log out of your account?'),
        findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Are you sure you want to log out of your account?'),
        findsNothing);
    expect(auth.signOutCalls, 0);
    expect(find.text('Overview'), findsOneWidget);

    // "Yes, log out" signs out and shows a notification.
    await tester.tap(find.text('Logout'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Yes, log out'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(auth.signOutCalls, 1);
    expect(find.text('You have been logged out.'), findsOneWidget);

    // Let the toast dismiss, then unmount to cancel remaining timers.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
  });
}
