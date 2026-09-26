import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_requests.dart';
import '../data/models/user.dart';


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

  Future<PasswordResetToken> requestPasswordReset(String email) =>
      _repo.requestPasswordReset(ForgotPasswordRequest(email: email));

  Future<void> resetPassword({
    required String token,
    required String password,
  }) =>
      _repo.resetPassword(
        ResetPasswordRequest(token: token, password: password),
      );

  Future<void> signOut() async {
    await _repo.logout();
    state = const AsyncData(null);
  }


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
