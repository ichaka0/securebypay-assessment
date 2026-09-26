import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_requests.dart';
import 'models/user.dart';

/// Talks to `/auth/*` and owns persisting/clearing the access token.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  bool get hasToken => _tokens.token != null;

  Future<User> register(RegisterRequest request) =>
      _authenticate('/auth/register', request.toJson());

  Future<User> login(LoginRequest request) =>
      _authenticate('/auth/login', request.toJson());

  Future<User> currentUser() async => User.fromJson(await _api.get('/auth/me'));

  Future<PasswordResetToken> requestPasswordReset(
    ForgotPasswordRequest request,
  ) async =>
      PasswordResetToken.fromJson(
        await _api.post('/auth/forgot-password', body: request.toJson()),
      );

  Future<void> resetPassword(ResetPasswordRequest request) =>
      _api.post('/auth/reset-password', body: request.toJson());

  Future<void> logout() => _tokens.clear();

  Future<User> _authenticate(String path, Map<String, dynamic> body) async {
    final json = await _api.post(path, body: body);
    await _tokens.save(json['accessToken'] as String);
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  ),
);
