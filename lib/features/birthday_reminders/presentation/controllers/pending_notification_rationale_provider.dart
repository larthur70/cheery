import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When true, the adaptive shell should show the notification rationale dialog.
final pendingNotificationRationaleProvider =
    NotifierProvider<PendingNotificationRationale, bool>(
  PendingNotificationRationale.new,
);

class PendingNotificationRationale extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;

  void clear() => state = false;
}
