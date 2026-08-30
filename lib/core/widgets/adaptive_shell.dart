import 'package:cheery/core/constants/app_breakpoints.dart';
import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/offline_status_banner.dart';
import 'package:cheery/core/widgets/web_app_footer.dart';
import 'package:cheery/core/widgets/web_nav_destination.dart';
import 'package:cheery/core/widgets/web_sidebar.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/auth/presentation/widgets/company_name_gate_overlay.dart';
import 'package:cheery/features/birthday_reminders/presentation/widgets/notification_permission_prompt_host.dart';
import 'package:cheery/features/onboarding/presentation/widgets/onboarding_tour_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Adaptive app chrome: custom web sidebar / mobile bottom navigation.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppBreakpoints.mobile;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final userName = profile?.fullName?.trim().isNotEmpty == true
        ? profile!.fullName!
        : 'Usuário';
    final userRole = profile?.isPro == true
        ? 'Plano Pro'
        : (profile?.plan == 'free' ? 'Plano Free' : (profile?.plan ?? 'Admin'));

    final shell = isWide
        ? _WebShell(
            selectedIndex: navigationShell.currentIndex,
            onSelect: _onSelect,
            userName: userName,
            userRole: userRole,
            onUserTap: () => context.push(AppRoutes.profile),
            child: navigationShell,
          )
        : _MobileShell(
            selectedIndex: navigationShell.currentIndex,
            onSelect: _onSelect,
            userName: userName,
            onUserTap: () => context.push(AppRoutes.profile),
            child: navigationShell,
          );

    return Column(
      children: [
        const OfflineStatusBanner(),
        Expanded(
          child: Stack(
            children: [
              shell,
              OnboardingTourOverlay(navigationShell: navigationShell),
              const CompanyNameGateOverlay(),
              const NotificationPermissionPromptHost(),
            ],
          ),
        ),
      ],
    );
  }
}

class _WebShell extends StatelessWidget {
  const _WebShell({
    required this.selectedIndex,
    required this.onSelect,
    required this.userName,
    required this.userRole,
    required this.onUserTap,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String userName;
  final String userRole;
  final VoidCallback onUserTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          WebSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            userName: userName,
            userRole: userRole,
            onUserTap: onUserTap,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                WebAppFooter(
                  onPrivacyTap: () => context.push(AppRoutes.privacy),
                  onTermsTap: () => context.push(AppRoutes.terms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.selectedIndex,
    required this.onSelect,
    required this.userName,
    required this.onUserTap,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String userName;
  final VoidCallback onUserTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppColors.sidebar,
            child: SafeArea(
              top: false,
              bottom: false,
              child: InkWell(
                onTap: onUserTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.cherrySoft,
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.cherry,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Meu perfil',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          NavigationBar(
            indicatorColor: AppColors.cherry,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            destinations: [
              for (final destination in WebNavItems.main)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
