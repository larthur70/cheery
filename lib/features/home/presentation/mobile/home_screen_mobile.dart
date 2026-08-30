import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_logo.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/home/presentation/widgets/home_empty_clients_cta.dart';
import 'package:cheery/features/home/presentation/widgets/home_mobile_birthday_card.dart';
import 'package:cheery/features/home/presentation/widgets/home_plan_status_card.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_section.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_ui_model.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_ui_model.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_connect_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreenMobile extends StatelessWidget {
  const HomeScreenMobile({
    required this.userFirstName,
    required this.todayBirthdays,
    required this.clientCount,
    this.nextBirthday,
    this.freePlanClientLimit = PlanLimits.freeMaxClients,
    this.showFreePlanUsage = true,
    this.whatsappReady = false,
    this.whatsappHeaderAction,
    this.notificationHeaderAction,
    this.onSendMessage,
    this.onUndoSent,
    this.onUpgradePlan,
    this.onAddFirstClient,
    super.key,
  });

  final String userFirstName;
  final List<TodayBirthdayUiModel> todayBirthdays;
  final NextBirthdayUiModel? nextBirthday;
  final int clientCount;
  final int freePlanClientLimit;
  final bool showFreePlanUsage;
  final bool whatsappReady;
  final Widget? whatsappHeaderAction;
  final Widget? notificationHeaderAction;
  final ValueChanged<TodayBirthdayUiModel>? onSendMessage;
  final ValueChanged<TodayBirthdayUiModel>? onUndoSent;
  final VoidCallback? onUpgradePlan;
  final VoidCallback? onAddFirstClient;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("d 'de' MMMM", 'pt_BR').format(DateTime.now());
    final capitalizedDate =
        '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const CheeryLogo(size: 34, wordmarkSize: 26),
                    const Spacer(),
                    ?notificationHeaderAction,
                    ?whatsappHeaderAction,
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $userFirstName!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hoje é $capitalizedDate',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                    const SizedBox(height: 20),
                    if (showFreePlanUsage) ...[
                      HomePlanStatusCard(
                        clientCount: clientCount,
                        limit: freePlanClientLimit,
                        onTap: onUpgradePlan,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const WhatsAppFreeUpgradeHint(),
                    const SizedBox(height: 28),
                    if (clientCount == 0 && onAddFirstClient != null)
                      KeyedSubtree(
                        key: OnboardingAnchors.homeBirthdays,
                        child: HomeEmptyClientsCta(
                          onAddClient: onAddFirstClient!,
                        ),
                      )
                    else ...[
                      Row(
                        key: OnboardingAnchors.homeBirthdays,
                        children: [
                          Text(
                            'Aniversariantes de hoje',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.cherry,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ),
            if (clientCount > 0 || onAddFirstClient == null) ...[
              if (todayBirthdays.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      'Nenhum aniversariante hoje.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverList.separated(
                    itemCount: todayBirthdays.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final birthday = todayBirthdays[index];
                      return HomeMobileBirthdayCard(
                        birthday: birthday,
                        onSendMessage: onSendMessage == null
                            ? null
                            : () => onSendMessage!(birthday),
                        onUndoSent: onUndoSent == null
                            ? null
                            : () => onUndoSent!(birthday),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  child: NextBirthdaySection(nextBirthday: nextBirthday),
                ),
              ),
            ] else
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
