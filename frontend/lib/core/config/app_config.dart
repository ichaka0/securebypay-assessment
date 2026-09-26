/// Compile-time configuration.
///
/// Override at build/run time, e.g.
/// `flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com/api`.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String appName = 'Myafrimall';
}
