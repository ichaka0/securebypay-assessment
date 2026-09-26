import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the access token (localStorage on web) with an in-memory cache,
/// so request interceptors can read it synchronously.
class TokenStorage {
  TokenStorage(this._prefs) : _token = _prefs.getString(_key);

  static const _key = 'auth.accessToken';

  final SharedPreferences _prefs;
  String? _token;

  String? get token => _token;

  Future<void> save(String token) async {
    _token = token;
    await _prefs.setString(_key, token);
  }

  Future<void> clear() async {
    _token = null;
    await _prefs.remove(_key);
  }
}

/// Overridden in `main.dart` once [SharedPreferences] has loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(sharedPreferencesProvider)),
);
