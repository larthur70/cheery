import 'package:cheery/core/theme/app_colors.dart';
import 'package:cheery/core/widgets/cheery_empty_state.dart';
import 'package:cheery/core/widgets/cheery_loading.dart';
import 'package:cheery/core/widgets/responsive_builder.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_failure.dart';
import 'package:cheery/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:cheery/features/calendar/presentation/mobile/calendar_mobile_screen.dart';
import 'package:cheery/features/calendar/presentation/web/calendar_web_screen.dart';
import 'package:cheery/features/messaging/presentation/widgets/open_send_whatsapp_flow.dart';
import 'package:cheery/features/messaging/presentation/widgets/set_birthday_message_sent_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adaptive entry for the calendar feature.
class CalendarEntryScreen extends ConsumerWidget {
  const CalendarEntryScreen({super.key});

  Future<void> _undoSent(
    BuildContext context,
    WidgetRef ref,
    CalendarBirthday birthday,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(calendarControllerProvider);

    return calendarAsync.when(
      loading: () => const ColoredBox(
        color: AppColors.background,
        child: CheeryLoading(message: 'Carregando calendário...'),
      ),
      error: (error, _) => ColoredBox(
        color: AppColors.background,
        child: CheeryEmptyState(
          title: 'Não foi possível carregar',
          message: error is CalendarFailure
              ? error.message
              : 'Tente novamente em instantes.',
          icon: Icons.error_outline,
          actionLabel: 'Tentar novamente',
          onAction: () =>
              ref.read(calendarControllerProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        final notifier = ref.read(calendarControllerProvider.notifier);
        return ResponsiveBuilder(
          mobile: (_) => CalendarMobileScreen(
            state: state,
            onSelectDate: notifier.selectDate,
            onPreviousMonth: notifier.previousMonth,
            onNextMonth: notifier.nextMonth,
            onToday: notifier.goToToday,
            onSend: (birthday) {
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
          ),
          desktop: (_) => CalendarWebScreen(
            state: state,
            onSelectDate: notifier.selectDate,
            onPreviousMonth: notifier.previousMonth,
            onNextMonth: notifier.nextMonth,
            onToday: notifier.goToToday,
            onSend: (birthday) {
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
          ),
        );
      },
    );
  }
}
