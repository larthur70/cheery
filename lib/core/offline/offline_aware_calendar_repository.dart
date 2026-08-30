import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/features/calendar/domain/calendar_birthday.dart';
import 'package:cheery/features/calendar/domain/calendar_repository.dart';
import 'package:cheery/features/clients/domain/client.dart';

class OfflineAwareCalendarRepository implements CalendarRepository {
  OfflineAwareCalendarRepository({
    required CalendarRepository remote,
    required OfflineStore store,
    required ConnectivityMonitor connectivity,
    required String Function() userId,
  })  : _remote = remote,
        _store = store,
        _connectivity = connectivity,
        _userId = userId;

  final CalendarRepository _remote;
  final OfflineStore _store;
  final ConnectivityMonitor _connectivity;
  final String Function() _userId;

  @override
  Future<List<CalendarBirthday>> listBirthdays() async {
    if (_connectivity.isOnline) {
      try {
        return await _remote.listBirthdays();
      } catch (error) {
        final cached = await _store.loadClients(_userId());
        if (cached.isNotEmpty || isLikelyNetworkError(error)) {
          return _fromClients(cached);
        }
        rethrow;
      }
    }
    return _fromClients(await _store.loadClients(_userId()));
  }

  List<CalendarBirthday> _fromClients(List<Client> clients) {
    return [
      for (final client in clients)
        CalendarBirthday(
          id: client.id,
          name: client.name,
          phone: client.phone,
          templateId: client.templateId,
          birthDate: client.birthDate,
          messageSentYear: client.messageSentYear,
          automaticEnabled: client.automaticEnabled,
        ),
    ];
  }
}
