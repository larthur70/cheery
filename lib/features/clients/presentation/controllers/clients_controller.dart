import 'package:cheery/features/auth/domain/profile.dart';
import 'package:cheery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cheery/features/auth/presentation/controllers/current_profile_provider.dart';
import 'package:cheery/features/billing/domain/plan_limits.dart';
import 'package:cheery/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/domain/clients_repository.dart';
import 'package:cheery/features/clients/domain/clients_sort.dart';
import 'package:cheery/features/clients/presentation/controllers/clients_repository_provider.dart';
import 'package:cheery/features/messaging/domain/whatsapp_phone.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/presentation/controllers/templates_repository_provider.dart';
import 'package:cheery/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientsControllerProvider =
    AsyncNotifierProvider<ClientsController, List<Client>>(ClientsController.new);

class ClientsController extends AsyncNotifier<List<Client>> {
  String _query = '';
  ClientsSort _sort = ClientsSort.birthday;
  List<Client> _all = const [];

  ClientsSort get sort => _sort;

  /// True when the account has at least one client (ignores search filter).
  bool get hasAnyClients => _all.isNotEmpty;

  /// Total clients for the account (ignores search filter).
  int get clientCount => _all.length;

  /// Normalized phone keys already used by this account.
  Set<String> get existingPhoneKeys {
    final keys = <String>{};
    for (final client in _all) {
      final key = WhatsAppPhone.uniquenessKey(client.phone);
      if (key != null) keys.add(key);
    }
    return keys;
  }

  ClientsRepository get _repository {
    final repository = ref.read(clientsRepositoryProvider);
    if (repository == null) {
      throw const ClientsNotReadyFailure();
    }
    return repository;
  }

  /// Keep calendar birthdays in sync after client mutations.
  void _syncCalendar() {
    final calendar = ref.read(calendarControllerProvider);
    if (calendar.hasValue) {
      ref.read(calendarControllerProvider.notifier).refresh();
    } else {
      ref.invalidate(calendarControllerProvider);
    }
  }

  void _assertCanAddClients(int additional) {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile != null && profile.isPro) return;
    if (_all.length + additional > PlanLimits.freeMaxClients) {
      ref.read(analyticsServiceProvider).trackLimiteAtingido(
            tipo: LimiteAnalyticsTipo.clientes,
            valorAtual: _all.length,
          );
      throw ClientsPlanLimitFailure();
    }
  }

  bool get _duranteOnboarding {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    return profile != null && !profile.onboardingCompleted;
  }

  void _assertPhoneAvailable(String phone, {String? excludeClientId}) {
    final key = WhatsAppPhone.uniquenessKey(phone);
    if (key == null) return;

    final duplicate = _all.any((client) {
      if (excludeClientId != null && client.id == excludeClientId) {
        return false;
      }
      return WhatsAppPhone.uniquenessKey(client.phone) == key;
    });

    if (duplicate) {
      throw const ClientsDuplicatePhoneFailure();
    }
  }

  void _assertPhonesAvailableInBatch(
    List<({String phone, String name})> rows,
  ) {
    final seen = <String>{};
    for (final row in rows) {
      final key = WhatsAppPhone.uniquenessKey(row.phone);
      if (key == null) continue;
      if (!seen.add(key) || existingPhoneKeys.contains(key)) {
        throw ClientsDuplicatePhoneFailure(
          'Telefone duplicado na importação: ${row.phone}. '
          'Cada número só pode pertencer a um cliente.',
        );
      }
    }
  }

  @override
  Future<List<Client>> build() async {
    // Rebuild whenever the signed-in user changes (login / logout / switch).
    final userId = ref.watch(
      authControllerProvider.select((async) => async.valueOrNull?.id),
    );
    if (userId == null) {
      _all = const [];
      return const [];
    }

    final repository = ref.watch(clientsRepositoryProvider);
    if (repository == null) {
      _all = const [];
      return const [];
    }

    return _loadInitial(repository, allowRetry: true);
  }

  Future<List<Client>> _loadInitial(
    ClientsRepository repository, {
    required bool allowRetry,
  }) async {
    try {
      final templatesRepo = ref.read(templatesRepositoryProvider);
      try {
        await templatesRepo?.ensureDefaultTemplate();
      } on TemplatesFailure {
        // Missing default while offline must not block the clients list.
      }
      _all = await repository.listClients();
      return _visible();
    } catch (error, stackTrace) {
      // Right after login the JWT/session can lag one frame behind navigation.
      if (allowRetry && _isTransientAuthOrNetworkError(error)) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        return _loadInitial(repository, allowRetry: false);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static bool _isTransientAuthOrNetworkError(Object error) {
    if (error is ClientsNetworkFailure) return true;
    if (error is ClientsUnknownFailure &&
        error.message.toLowerCase().contains('não autenticado')) {
      return true;
    }
    if (error is TemplatesFailure &&
        error.message.toLowerCase().contains('não autenticado')) {
      return true;
    }
    if (error is TemplatesNetworkFailure) return true;
    return false;
  }

  Future<void> refresh() async {
    try {
      final templatesRepo = ref.read(templatesRepositoryProvider);
      try {
        await templatesRepo?.ensureDefaultTemplate();
      } on TemplatesFailure {
        // Keep the cached list usable if the default template cannot be created.
      }
      _all = await _repository.listClients();
      state = AsyncData(_visible());
      _syncCalendar();
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Instant local filter — keeps focus and does not show a full-page loader.
  void search(String query) {
    _query = query.trim();
    if (!state.hasValue) return;
    state = AsyncData(_visible());
  }

  void setSort(ClientsSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    if (!state.hasValue) return;
    state = AsyncData(_visible());
  }

  Future<Client> createClient({
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    _assertCanAddClients(1);
    _assertPhoneAvailable(phone);
    final duranteOnboarding = _duranteOnboarding;
    final created = await _repository.createClient(
      name: name,
      phone: phone,
      birthDate: birthDate,
      templateId: templateId,
      automaticEnabled: automaticEnabled,
    );
    // Track before refresh so a list reload failure cannot drop the event.
    await ref.read(analyticsServiceProvider).trackClienteCriadoManual(
          duranteOnboarding: duranteOnboarding,
        );
    await refresh();
    return created;
  }

  Future<List<Client>> createClientsBatch(
    List<
        ({
          String name,
          String phone,
          DateTime birthDate,
          String templateId,
          bool automaticEnabled,
        })> rows,
  ) async {
    _assertCanAddClients(rows.length);
    _assertPhonesAvailableInBatch(
      rows.map((row) => (phone: row.phone, name: row.name)).toList(),
    );
    final created = await _repository.createClientsBatch(rows);
    await refresh();
    return created;
  }

  Future<Client> updateClient({
    required String id,
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    _assertPhoneAvailable(phone, excludeClientId: id);
    final updated = await _repository.updateClient(
      id: id,
      name: name,
      phone: phone,
      birthDate: birthDate,
      templateId: templateId,
      automaticEnabled: automaticEnabled,
    );
    await refresh();
    return updated;
  }

  Future<Client> setBirthdayMessageSent({
    required String id,
    required bool sent,
  }) async {
    final updated = await _repository.setBirthdayMessageSent(
      id: id,
      sent: sent,
    );
    await refresh();
    return updated;
  }

  Future<void> deleteClient(String id) async {
    await deleteClients([id]);
  }

  Future<void> deleteClients(List<String> ids) async {
    await _repository.deleteClients(ids);
    await refresh();
  }

  List<Client> _visible() {
    var list = List<Client>.from(_all);

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      final qDigits = _query.replaceAll(RegExp(r'\D'), '');
      list = list.where((client) {
        final nameMatch = client.name.toLowerCase().contains(q);
        final phoneLower = client.phone.toLowerCase();
        final phoneDigits = client.phone.replaceAll(RegExp(r'\D'), '');
        final phoneMatch = phoneLower.contains(q) ||
            (qDigits.isNotEmpty && phoneDigits.contains(qDigits));
        return nameMatch || phoneMatch;
      }).toList();
    }

    return _sortList(list);
  }

  List<Client> _sortList(List<Client> list) {
    final sorted = List<Client>.from(list);
    switch (_sort) {
      case ClientsSort.birthday:
        sorted.sort((a, b) {
          final byDay = _birthdayKey(a.birthDate).compareTo(
            _birthdayKey(b.birthDate),
          );
          if (byDay != 0) return byDay;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case ClientsSort.name:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return sorted;
  }

  int _birthdayKey(DateTime date) => date.month * 100 + date.day;
}
