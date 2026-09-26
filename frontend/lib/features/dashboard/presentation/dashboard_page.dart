import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/widgets/logout_confirm_dialog.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/common.dart';
import 'widgets/overview_section.dart';
import 'widgets/recent_shipments_section.dart';
import 'widgets/side_nav.dart';

/// Main dashboard. Fixed sidebar on desktop; app bar + drawer below 1024px.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const double _maxContentWidth = 1200;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink(); // router redirects

    final desktop = context.isDesktop;

    Future<void> logout() async {
      final confirmed = await confirmLogout(context);
      if (!confirmed || !context.mounted) return;
      // Show the toast first: it lives in the root overlay and survives the
      // redirect to Sign in, whereas this page's context does not.
      AppSnackbar.info(context, 'You have been logged out.');
      await ref.read(authControllerProvider.notifier).signOut();
    }

    void select(NavDestination item) {
      if (!desktop) Navigator.of(context).maybePop(); // close drawer
      if (item != NavDestination.dashboard) {
        AppSnackbar.info(context, '${item.label} is coming soon.');
      }
    }

    SideNav nav({required double topGap}) => SideNav(
          selected: NavDestination.dashboard,
          onSelect: select,
          userName: user.fullName,
          userInitials: user.initials,
          onLogout: logout,
          topGap: topGap,
        );

    final padding = switch (context.screenSize) {
      ScreenSize.desktop => const EdgeInsets.fromLTRB(40, 28, 30, 40),
      ScreenSize.tablet => const EdgeInsets.all(24),
      ScreenSize.mobile => const EdgeInsets.fromLTRB(16, 16, 16, 32),
    };

    final content = SingleChildScrollView(
      padding: padding,
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PageIntro(),
              SizedBox(height: 16),
              BannerCarousel(),
              SizedBox(height: 16),
              OverviewSection(),
              SizedBox(height: 28),
              RecentShipmentsSection(),
            ],
          ),
        ),
      ),
    );

    if (desktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            nav(topGap: 132),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 0,
        title: Text('Dashboard', style: AppTextStyles.subtitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: UserAvatar(initials: user.initials),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      drawer: Drawer(
        width: SideNav.width,
        backgroundColor: AppColors.sidebar,
        shape: const RoundedRectangleBorder(),
        child: nav(topGap: 32),
      ),
      body: content,
    );
  }
}

/// Heading block at the top of the content area.
class _PageIntro extends StatelessWidget {
  const _PageIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invite & Earn', style: AppTextStyles.subtitle),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Keep track of all your addresses, customs updates. Edit, Delete, '
            'Update and see all your saved addresses',
            style: AppTextStyles.tiny.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
