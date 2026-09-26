import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/sign_in_page.dart';
import 'package:frontend/features/auth/presentation/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request with [statusCode] and [body] (no network).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? _,
          Future<void>? __) async =>
      ResponseBody.fromString(body, statusCode, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  void close({bool force = false}) {}
}

Future<void> _pump(WidgetTester tester, Widget page,
    {HttpClientAdapter? adapter, Size size = const Size(1440, 1024)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final storage = TokenStorage(prefs);
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'));
  if (adapter != null) dio.httpClientAdapter = adapter;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider
            .overrideWithValue(ApiClient(tokenStorage: storage, dio: dio)),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: page),
    ),
  );
  await tester.pump();
}

void main() {
  const sizes = {
    'mobile': Size(390, 844),
    'tablet': Size(768, 1024),
    'desktop': Size(1440, 1024),
  };
  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('Auth pages render without overflow on $name', (tester) async {
      await _pump(tester, const SignUpPage(), size: size);
      expect(tester.takeException(), isNull);
      expect(find.text('Create an account'), findsOneWidget);

      await _pump(tester, const SignInPage(), size: size);
      expect(tester.takeException(), isNull);
      expect(find.text('Sign in to your account'), findsOneWidget);
    });
  }

  testWidgets('Sign up shows validation errors for an empty form',
      (tester) async {
    await _pump(tester, const SignUpPage());

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('First name is required'), findsOneWidget);
    expect(find.text('Last name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Sign in shows the server error when credentials are wrong',
      (tester) async {
    await _pump(
      tester,
      const SignInPage(),
      adapter: _FakeAdapter(
          401, '{"statusCode":401,"message":"Invalid email or password"}'),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass1');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    final toast = find.text('Invalid email or password');
    expect(toast, findsOneWidget);
    // Notifications are shown at the top of the screen.
    expect(tester.getTopLeft(toast).dy, lessThan(200));

    // Let the toast auto-dismiss so no timer is left pending.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(toast, findsNothing);
  });

  testWidgets('Password visibility can be toggled', (tester) async {
    await _pump(tester, const SignInPage());

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
