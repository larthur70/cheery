import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/home/presentation/widgets/free_plan_clients_bar.dart';
import 'package:cheery/features/home/presentation/widgets/home_empty_clients_cta.dart';
import 'package:cheery/features/home/presentation/widgets/home_greeting_header.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_section.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_ui_model.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_card.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_ui_model.dart';
import 'package:cheery/features/onboarding/domain/onboarding_anchors.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_connect_entry.dart';
import 'package:flutter/material.dart';

class HomeScreenWeb extends StatelessWidget {
  const HomeScreenWeb({
    required this.userFirstName,
    required this.todayBirthdays,
    required this.clientCount,
    this.nextBirthday,
    this.freePlanClientLimit = PlanLimits.freeMaxClients,
    this.showFreePlanUsage = true,
    this.whatsappReady = false,
    this.whatsappHeaderAction,
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
  final ValueChanged<TodayBirthdayUiModel>? onSendMessage;
  final ValueChanged<TodayBirthdayUiModel>? onUndoSent;
  final VoidCallback? onUpgradePlan;
  final VoidCallback? onAddFirstClient;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: HomeGreetingHeader(
                      userFirstName: userFirstName,
                      date: DateTime.now(),
                    ),
                  ),
                  ?whatsappHeaderAction,
                ],
              ),
              const SizedBox(height: 36),
              if (clientCount == 0 && onAddFirstClient != null)
                KeyedSubtree(
                  key: OnboardingAnchors.homeBirthdays,
                  child: HomeEmptyClientsCta(onAddClient: onAddFirstClient!),
                )
              else ...[
                Text(
                  key: OnboardingAnchors.homeBirthdays,
                  'Aniversariantes de hoje',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.cherry,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                if (todayBirthdays.isEmpty)
                  Text(
                    'Nenhum aniversariante hoje.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  )
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final birthday in todayBirthdays)
                        TodayBirthdayCard(
                          birthday: birthday,
                          onSendMessage: onSendMessage == null
                              ? null
                              : () => onSendMessage!(birthday),
                          onUndoSent: onUndoSent == null
                              ? null
                              : () => onUndoSent!(birthday),
                        ),
                    ],
                  ),
                const SizedBox(height: 36),
                NextBirthdaySection(nextBirthday: nextBirthday),
              ],
              const SizedBox(height: 40),
              if (showFreePlanUsage) ...[
                FreePlanClientsBar(
                  clientCount: clientCount,
                  limit: freePlanClientLimit,
                  onUpgrade: onUpgradePlan,
                ),
                const SizedBox(height: 16),
              ],
              const WhatsAppFreeUpgradeHint(),
            ],
          ),
        ),
      ),
    );
  }
}
