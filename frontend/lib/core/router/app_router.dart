import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../theme/app_colors.dart';
import 'routes.dart';


final routerProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod auth changes into GoRouter's refresh mechanism.
  final authChanges = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref
    ..onDispose(authChanges.dispose)
    ..listen(
      authControllerProvider,
      (_, next) => authChanges.value = next,
      fireImmediately: true,
    );

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = authChanges.value;
      final location = state.matchedLocation;
      const authPages = {
        Routes.signIn,
        Routes.signUp,
        Routes.forgotPassword,
        Routes.resetPassword,
      };
      final onAuthPage = authPages.contains(location);

      if (auth.isLoading && !auth.hasValue) {
        return location == Routes.splash ? null : Routes.splash;
      }
      final signedIn = auth.valueOrNull != null;
      if (!signedIn) return onAuthPage ? null : Routes.signIn;
      if (onAuthPage || location == Routes.splash) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const _SplashPage(),
      ),
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const SignInPage()),
      ),
      GoRoute(
        path: Routes.signUp,
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const SignUpPage()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        pageBuilder: (_, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: Routes.resetPassword,
        pageBuilder: (_, state) => NoTransitionPage(
          key: state.pageKey,
          child: ResetPasswordPage(
            token: state.uri.queryParameters['token'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (_, __) => const DashboardPage(),
      ),
    ],
  );
});

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
}
