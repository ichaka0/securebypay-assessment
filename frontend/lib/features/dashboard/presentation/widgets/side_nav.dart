import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import 'common.dart';

enum NavDestination {
  dashboard('Dashboard', Icons.grid_view_outlined),
  shipments('Shipments', Icons.inventory_2_outlined),
  services('Our Services', Icons.language_outlined),
  notifications('Notifications', Icons.notifications_none_outlined),
  wallet('Wallet', Icons.account_balance_wallet_outlined),
  addresses('My Addresses', Icons.location_on_outlined),
  inviteEarn('Invite & Earn', Icons.card_giftcard_outlined),
  helpCenter('Help Center', Icons.headset_mic_outlined);

  const NavDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Left navigation: menu items, the signed-in user and Logout.
/// Rendered permanently on desktop and inside a [Drawer] on smaller screens.
class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.userName,
    required this.userInitials,
    required this.onLogout,
    this.topGap = 132,
  });

  static const double width = 232;

  /// Space above the menu (matches Figma on desktop; smaller in the drawer).
  final double topGap;

  final NavDestination selected;
  final ValueChanged<NavDestination> onSelect;
  final String userName;
  final String userInitials;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final nameParts = userName.split(' ');
    return Container(
      width: width,
      color: AppColors.sidebar,
      padding: const EdgeInsets.fromLTRB(28, 0, 20, 28),
      child: SafeArea(
        // Scrolls on short viewports; otherwise pins the user block to the
        // bottom like the design.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(child: _content(nameParts)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(List<String> nameParts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: topGap),
        for (final item in NavDestination.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _NavTile(
              item: item,
              selected: item == selected,
              onTap: () => onSelect(item),
            ),
          ),
        const Spacer(),
        Row(
          children: [
            UserAvatar(initials: userInitials, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nameParts.length > 1
                    ? '${nameParts.first}\n${nameParts.skip(1).join(' ')}'
                    : userName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _NavButton(
          icon: Icons.logout_rounded,
          label: 'Logout',
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavDestination item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.textSecondary;
    return Material(
      color: selected ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Semantics(
          selected: selected,
          button: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
