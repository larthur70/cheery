import 'package:cheery/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists birthday send status and refreshes home + calendar lists.
Future<void> setBirthdayMessageSentStatus(
  WidgetRef ref, {
  required String clientId,
  required bool sent,
}) async {
  await ref.read(clientsControllerProvider.notifier).setBirthdayMessageSent(
        id: clientId,
        sent: sent,
      );

  try {
    await ref.read(calendarControllerProvider.notifier).refresh();
  } catch (_) {
    // Calendar may not be ready; clients refresh is enough for home.
  }
}
