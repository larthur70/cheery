import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/platform/store_compliance.dart';
import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/utils/birthday_date.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/presentation/controllers/client_form_controller.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:cheery/features/clients/presentation/mobile/client_form_mobile_screen.dart';
import 'package:cheery/features/clients/presentation/widgets/client_form_view.dart';
import 'package:cheery/features/home/presentation/mobile/home_screen_mobile.dart';
import 'package:cheery/features/home/presentation/web/home_screen_web.dart';
import 'package:cheery/features/home/presentation/widgets/next_birthday_ui_model.dart';
import 'package:cheery/features/home/presentation/widgets/today_birthday_ui_model.dart';
import 'package:cheery/features/messaging/presentation/widgets/open_send_whatsapp_flow.dart';
import 'package:cheery/features/messaging/presentation/widgets/set_birthday_message_sent_status.dart';
import 'package:cheery/features/home/presentation/widgets/home_notification_entry.dart';
import 'package:cheery/features/whatsapp_automation/presentation/widgets/whatsapp_connect_entry.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Adaptive entry for the home dashboard.
class HomeEntryScreen extends ConsumerWidget {
  const HomeEntryScreen({super.key});

  static const _freePlanClientLimit = PlanLimits.freeMaxClients;

  static List<TodayBirthdayUiModel> _todaysBirthdays(List<Client> clients) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final matches = clients.where((client) {
      return BirthdayDate.matchesCalendarDay(client.birthDate, today);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return [
      for (final client in matches)
        TodayBirthdayUiModel(
          id: client.id,
          name: client.name,
          phone: client.phone,
          templateId: client.templateId,
          age: _ageTurningToday(client.birthDate, today),
          messageSent: client.isBirthdayMessageSentThisYear,
          automaticEnabled: client.automaticEnabled,
        ),
    ];
  }

  /// Next birthday strictly after today (earliest upcoming within a year).
  static NextBirthdayUiModel? _nextBirthday(List<Client> clients) {
    if (clients.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    NextBirthdayUiModel? best;

    for (final client in clients) {
      final next = _nextOccurrenceAfterToday(client.birthDate, today);
      final daysUntil = next.difference(today).inDays;
      if (best == null ||
          daysUntil < best.daysUntil ||
          (daysUntil == best.daysUntil &&
              client.name.toLowerCase().compareTo(best.name.toLowerCase()) <
                  0)) {
        best = NextBirthdayUiModel(
          id: client.id,
          name: client.name,
          nextOccurrence: next,
          daysUntil: daysUntil,
        );
      }
    }
    return best;
  }

  static DateTime _nextOccurrenceAfterToday(
    DateTime birthDate,
    DateTime today,
  ) {
    var next = BirthdayDate.occurrenceInYear(birthDate, today.year);
    if (!next.isAfter(today)) {
      next = BirthdayDate.occurrenceInYear(birthDate, today.year + 1);
    }
    return next;
  }

  static int _ageTurningToday(DateTime birthDate, DateTime today) {
    return today.year - birthDate.year;
  }

  static String _firstName(String? fullName) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) return 'aí';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _undoSent(
    BuildContext context,
    WidgetRef ref,
    TodayBirthdayUiModel birthday,
  ) async {
    try {
      await setBirthdayMessageSentStatus(
        ref,
        clientId: birthday.id,
        sent: false,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível desfazer o status de enviado.'),
          ),
        );
      }
    }
  }

  Future<void> _openAddFirstClient(
    BuildContext context,
    WidgetRef ref, {
    required bool mobile,
  }) async {
    await ref.read(clientFormControllerProvider.notifier).openCreate();
    if (!context.mounted) return;
    if (mobile) {
      await showClientFormMobile(context);
    } else {
      await showClientFormDialog(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);
    final clientsAsync = ref.watch(clientsControllerProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final firstName = _firstName(profileAsync.valueOrNull?.fullName);

    if (authAsync.isLoading || authAsync.valueOrNull == null) {
      return const ColoredBox(
        color: AppColors.background,
        child: CheeryLoading(message: 'Carregando aniversariantes...'),
      );
    }

    return clientsAsync.when(
      loading: () => const ColoredBox(
        color: AppColors.background,
        child: CheeryLoading(message: 'Carregando aniversariantes...'),
      ),
      error: (error, _) => ColoredBox(
        color: AppColors.background,
        child: CheeryEmptyState(
          title: 'Não foi possível carregar',
          message: error is ClientsFailure
              ? error.message
              : 'Tente novamente em instantes.',
          icon: Icons.error_outline,
          actionLabel: 'Tentar novamente',
          onAction: () =>
              ref.read(clientsControllerProvider.notifier).refresh(),
        ),
      ),
      data: (clients) {
        final total =
            ref.read(clientsControllerProvider.notifier).clientCount;
        final todayBirthdays = _todaysBirthdays(clients);
        final nextBirthday = _nextBirthday(clients);
        final isFree = profileAsync.valueOrNull?.isFree ?? true;
        final isWhatsAppReady =
            profileAsync.valueOrNull?.isWhatsAppReady ?? false;

        return ResponsiveBuilder(
          mobile: (_) => HomeScreenMobile(
            userFirstName: firstName,
            todayBirthdays: todayBirthdays,
            nextBirthday: nextBirthday,
            clientCount: total,
            freePlanClientLimit: _freePlanClientLimit,
            showFreePlanUsage: isFree,
            whatsappReady: isWhatsAppReady,
            whatsappHeaderAction: const WhatsAppConnectEntry(compact: true),
            notificationHeaderAction: const HomeNotificationEntry(),
            onSendMessage: (birthday) {
              openSendWhatsAppFlow(
                context,
                ref,
                clientId: birthday.id,
                clientName: birthday.name,
                phone: birthday.phone,
                templateId: birthday.templateId,
              );
            },
            onUndoSent: (birthday) => _undoSent(context, ref, birthday),
            onUpgradePlan: StoreCompliance.hideExternalPayments
                ? null
                : () => context.push(
                      AppRoutes.profilePlansFrom(
                        AssinaturaOrigemGatilho.limiteClientes.wireValue,
                      ),
                    ),
            onAddFirstClient: () =>
                _openAddFirstClient(context, ref, mobile: true),
          ),
          desktop: (_) => HomeScreenWeb(
            userFirstName: firstName,
            todayBirthdays: todayBirthdays,
            nextBirthday: nextBirthday,
            clientCount: total,
            freePlanClientLimit: _freePlanClientLimit,
            showFreePlanUsage: isFree,
            whatsappReady: isWhatsAppReady,
            whatsappHeaderAction: const WhatsAppConnectEntry(),
            onSendMessage: (birthday) {
              openSendWhatsAppFlow(
                context,
                ref,
                clientId: birthday.id,
                clientName: birthday.name,
                phone: birthday.phone,
                templateId: birthday.templateId,
              );
            },
            onUndoSent: (birthday) => _undoSent(context, ref, birthday),
            onUpgradePlan: () => context.push(
              AppRoutes.profilePlansFrom(
                AssinaturaOrigemGatilho.limiteClientes.wireValue,
              ),
            ),
            onAddFirstClient: () =>
                _openAddFirstClient(context, ref, mobile: false),
          ),
        );
      },
    );
  }
}
