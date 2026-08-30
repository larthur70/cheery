import 'package:cheery/features/birthday_reminders/data/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});
