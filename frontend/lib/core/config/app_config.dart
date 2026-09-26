import 'package:flutter/foundation.dart';

/// App-wide configuration.
abstract final class AppConfig {
  /// Deployed NestJS API on Render.
  static const String productionApiUrl =
      'https://securebypay-assessment-wf1p.onrender.com/api';

  /// Local backend started with `npm run start:dev`.
  static const String localApiUrl = 'http://localhost:3000/api';

  /// Optional build-time override, e.g.
  /// `flutter run -d chrome --dart-define=API_BASE_URL=https://staging.example.com/api`.
  static const String _apiUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Base URL for API calls: the `API_BASE_URL` override if given, otherwise
  /// the Render API in release builds (the Vercel deployment) and the local
  /// backend while developing.
  static String get apiBaseUrl {
    final override = _apiUrlOverride.trim();
    if (override.isNotEmpty) return normaliseApiUrl(override);
    return kReleaseMode ? productionApiUrl : localApiUrl;
  }

  /// Every backend route lives under the `/api` global prefix, so accept a
  /// bare host (`https://host` or `https://host/`) and add it:
  /// `https://host` -> `https://host/api`.
  @visibleForTesting
  static String normaliseApiUrl(String url) {
    final trimmed = url.replaceAll(RegExp(r'/+$'), '');
    return trimmed.endsWith('/api') ? trimmed : '$trimmed/api';
  }

  static const String appName = 'Myafrimall';
}
