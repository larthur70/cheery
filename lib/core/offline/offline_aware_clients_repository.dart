import 'dart:async';

import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_engine.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/features/clients/domain/client.dart';
import 'package:cheery/features/clients/domain/clients_failure.dart';
import 'package:cheery/features/clients/domain/clients_repository.dart';
import 'package:uuid/uuid.dart';

class OfflineAwareClientsRepository implements ClientsRepository {
  OfflineAwareClientsRepository({
    required ClientsRepository remote,
    required OfflineStore store,
    required SyncQueue queue,
    required SyncEngine engine,
    required ConnectivityMonitor connectivity,
    required String Function() userId,
  })  : _remote = remote,
        _store = store,
        _queue = queue,
        _engine = engine,
        _connectivity = connectivity,
        _userId = userId;

  final ClientsRepository _remote;
  final OfflineStore _store;
  final SyncQueue _queue;
  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  final String Function() _userId;
  final _uuid = const Uuid();

  @override
  Future<List<Client>> listClients({String? query}) async {
    if (_connectivity.isOnline) {
      try {
        final remote = await _remote.listClients(query: query);
        final pending = await _queue.list();
        final merged = applyClientOps(remote, pending);
        await _store.saveClients(_userId(), merged);
        return merged;
      } catch (error) {
        final cached = await _store.loadClients(_userId());
        if (cached.isNotEmpty || isLikelyNetworkError(error)) return cached;
        rethrow;
      }
    }
    return _store.loadClients(_userId());
  }

  @override
  Future<Client> createClient({
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    final now = DateTime.now().toUtc();
    final client = Client(
      id: _uuid.v4(),
      userId: _userId(),
      name: name.trim(),
      phone: phone.trim(),
      birthDate: birthDate,
      templateId: templateId,
      templateName: await _templateName(templateId),
      automaticEnabled: automaticEnabled,
      createdAt: now,
      updatedAt: now,
    );
    await _writeLocal(client);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.client,
        action: SyncAction.create,
        entityId: client.id,
        payload: client.toJson(),
        createdAt: now,
      ),
    );
    unawaited(_engine.process());
    return client;
  }

  @override
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
    final created = <Client>[];
    for (final row in rows) {
      created.add(
        await createClient(
          name: row.name,
          phone: row.phone,
          birthDate: row.birthDate,
          templateId: row.templateId,
          automaticEnabled: row.automaticEnabled,
        ),
      );
    }
    return created;
  }

  @override
  Future<Client> updateClient({
    required String id,
    required String name,
    required String phone,
    required DateTime birthDate,
    required String templateId,
    bool automaticEnabled = false,
  }) async {
    final current = await _requireLocal(id);
    final updated = current.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      birthDate: birthDate,
      templateId: templateId,
      templateName: await _templateName(templateId) ?? current.templateName,
      automaticEnabled: automaticEnabled,
      updatedAt: DateTime.now().toUtc(),
    );
    await _writeLocal(updated);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.client,
        action: SyncAction.update,
        entityId: id,
        payload: updated.toJson(),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
    return updated;
  }

  @override
  Future<Client> setBirthdayMessageSent({
    required String id,
    required bool sent,
  }) async {
    final current = await _requireLocal(id);
    final updated = current.copyWith(
      messageSentYear: sent ? DateTime.now().year : null,
      updatedAt: DateTime.now().toUtc(),
    );
    await _writeLocal(updated);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.client,
        action: SyncAction.setMessageSent,
        entityId: id,
        payload: updated.toJson(),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
    return updated;
  }

  @override
  Future<void> deleteClient(String id) async {
    await deleteClients([id]);
  }

  @override
  Future<void> deleteClients(List<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet();
    if (unique.isEmpty) return;
    final cached = await _store.loadClients(_userId());
    cached.removeWhere((client) => unique.contains(client.id));
    await _store.saveClients(_userId(), cached);
    for (final id in unique) {
      await _queue.enqueue(
        SyncOperation(
          id: '',
          seq: 0,
          entity: SyncEntity.client,
          action: SyncAction.delete,
          entityId: id,
          payload: const {},
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
    unawaited(_engine.process());
  }

  Future<void> _writeLocal(Client client) async {
    final cached = await _store.loadClients(_userId());
    final next = [
      for (final item in cached)
        if (item.id != client.id) item,
      client,
    ];
    await _store.saveClients(_userId(), next);
  }

  Future<Client> _requireLocal(String id) async {
    final cached = await _store.loadClients(_userId());
    for (final client in cached) {
      if (client.id == id) return client;
    }
    throw const ClientsNotFoundFailure();
  }

  Future<String?> _templateName(String templateId) async {
    final templates = await _store.loadTemplates(_userId());
    for (final template in templates) {
      if (template.id == templateId) return template.name;
    }
    return null;
  }
}

List<Client> applyClientOps(List<Client> base, List<SyncOperation> ops) {
  final map = <String, Client>{for (final client in base) client.id: client};
  for (final op in ops) {
    if (op.entity != SyncEntity.client) continue;
    switch (op.action) {
      case SyncAction.create:
      case SyncAction.update:
      case SyncAction.setMessageSent:
        map[op.entityId] = Client.fromJson(op.payload);
      case SyncAction.delete:
        map.remove(op.entityId);
    }
  }
  return map.values.toList();
}
