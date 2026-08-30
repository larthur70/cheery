import 'package:cheery/core/offline/offline_aware_calendar_repository.dart';
import 'package:cheery/core/offline/offline_providers.dart';
import 'package:cheery/core/providers/supabase_provider.dart';
import 'package:cheery/features/calendar/data/calendar_repository_impl.dart';
import 'package:cheery/features/calendar/domain/calendar_failure.dart';
import 'package:cheery/features/calendar/domain/calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarRepositoryProvider = Provider<CalendarRepository?>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  if (!ready) return null;
  final supabase = ref.watch(supabaseClientProvider);
  final remote = CalendarRepositoryImpl(supabase);
  return OfflineAwareCalendarRepository(
    remote: remote,
    store: ref.watch(offlineStoreProvider),
    connectivity: ref.watch(connectivityMonitorProvider),
    userId: () {
      final id = supabase.auth.currentUser?.id;
      if (id == null) {
        throw const CalendarUnknownFailure('Usuário não autenticado.');
      }
      return id;
    },
  );
});
