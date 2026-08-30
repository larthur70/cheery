import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/web_nav_destination.dart';
import 'package:cheery/core/widgets/web_sidebar_brand.dart';
import 'package:cheery/core/widgets/web_sidebar_user_card.dart';
import 'package:flutter/material.dart';

/// Reusable left sidebar for all Cheery web screens.
class WebSidebar extends StatelessWidget {
  const WebSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.userName = 'Ana Silva',
    this.userRole = 'Admin',
    this.userAvatarUrl,
    this.onUserTap,
    this.width = 240,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String userName;
  final String userRole;
  final String? userAvatarUrl;
  final VoidCallback? onUserTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sidebar,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WebSidebarBrand(),
                const SizedBox(height: 36),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: WebNavItems.main.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final destination = WebNavItems.main[index];
                      return _SidebarNavItem(
                        label: destination.label,
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        selected: index == selectedIndex,
                        onTap: () => onDestinationSelected(index),
                      );
                    },
                  ),
                ),
                WebSidebarUserCard(
                  name: userName,
                  role: userRole,
                  avatarUrl: userAvatarUrl,
                  onTap: onUserTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.ink;
    final background = selected ? AppColors.cherry : Colors.transparent;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: foreground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
