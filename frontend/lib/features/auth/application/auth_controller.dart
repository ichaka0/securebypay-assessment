import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_requests.dart';
import '../data/models/user.dart';

/// Session state: `AsyncData(null)` = signed out, `AsyncData(user)` = signed in,
/// `AsyncLoading` = restoring a saved session on start-up.
///
/// [signIn]/[signUp] throw [ApiException] on failure so forms can show field
/// errors; the session state is left unchanged in that case.
class AuthController extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    // Expired/revoked token on any request -> sign out.
    ref.read(apiClientProvider).onUnauthorized = () {
      if (state.valueOrNull != null) signOut();
    };

    if (!_repo.hasToken) return null;
    try {
      return await _repo.currentUser();
    } on ApiException catch (e) {
      if (e.isUnauthorized) await _repo.logout();
      return null;
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    final user =
        await _repo.login(LoginRequest(email: email, password: password));
    state = AsyncData(user);
    return user;
  }

  Future<User> signUp(RegisterRequest request) async {
    final user = await _repo.register(request);
    state = AsyncData(user);
    return user;
  }

  Future<void> signOut() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  /// Re-fetches the profile (e.g. after the wallet balance changed).
  Future<void> refreshUser() async {
    try {
      state = AsyncData(await _repo.currentUser());
    } on ApiException {
      // Keep the current user; the 401 path is handled by onUnauthorized.
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);
