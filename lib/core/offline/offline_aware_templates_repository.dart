import 'dart:async';

import 'package:cheery/core/offline/connectivity_monitor.dart';
import 'package:cheery/core/offline/network_error.dart';
import 'package:cheery/core/offline/offline_store.dart';
import 'package:cheery/core/offline/sync_engine.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:cheery/core/offline/sync_queue.dart';
import 'package:cheery/features/templates/data/templates_repository_impl.dart';
import 'package:cheery/features/templates/domain/template.dart';
import 'package:cheery/features/templates/domain/template_approval_status.dart';
import 'package:cheery/features/templates/domain/template_summary.dart';
import 'package:cheery/features/templates/domain/templates_failure.dart';
import 'package:cheery/features/templates/domain/templates_repository.dart';
import 'package:uuid/uuid.dart';

class OfflineAwareTemplatesRepository implements TemplatesRepository {
  OfflineAwareTemplatesRepository({
    required TemplatesRepository remote,
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

  final TemplatesRepository _remote;
  final OfflineStore _store;
  final SyncQueue _queue;
  final SyncEngine _engine;
  final ConnectivityMonitor _connectivity;
  final String Function() _userId;
  final _uuid = const Uuid();

  @override
  Future<List<Template>> listTemplates() async {
    if (_connectivity.isOnline) {
      try {
        final remote = await _remote.listTemplates();
        final pending = await _queue.list();
        final merged = applyTemplateOps(remote, pending);
        await _store.saveTemplates(_userId(), merged);
        return merged;
      } catch (error) {
        final cached = await _store.loadTemplates(_userId());
        if (cached.isNotEmpty || isLikelyNetworkError(error)) return cached;
        rethrow;
      }
    }
    return _store.loadTemplates(_userId());
  }

  @override
  Future<List<TemplateSummary>> listSummaries() async {
    final templates = await listTemplates();
    return [for (final template in templates) _toSummary(template)];
  }

  @override
  Future<Template> getById(String id) async {
    final templates = await listTemplates();
    for (final template in templates) {
      if (template.id == id) return template;
    }
    throw const TemplatesNotFoundFailure();
  }

  @override
  Future<TemplateSummary> getDefaultTemplate() async {
    final templates = await listTemplates();
    for (final template in templates) {
      if (template.isDefault) return _toSummary(template);
    }
    if (templates.isNotEmpty) return _toSummary(templates.first);
    throw const TemplatesDefaultMissingFailure();
  }

  @override
  Future<TemplateSummary> ensureDefaultTemplate() async {
    try {
      return await getDefaultTemplate();
    } on TemplatesDefaultMissingFailure {
      if (_connectivity.isOnline) {
        try {
          final summary = await _remote.ensureDefaultTemplate();
          await listTemplates();
          return summary;
        } catch (_) {
          return _createLocalDefault();
        }
      }
      return _createLocalDefault();
    }
  }

  Future<TemplateSummary> _createLocalDefault() async {
    final now = DateTime.now().toUtc();
    final template = Template(
      id: _uuid.v4(),
      userId: _userId(),
      name: TemplatesRepositoryImpl.defaultTemplateName,
      message: TemplatesRepositoryImpl.defaultTemplateMessage,
      variables: TemplatesRepositoryImpl.defaultTemplateVariables,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
    await _writeLocal(template);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.template,
        action: SyncAction.create,
        entityId: template.id,
        payload: template.toJson(),
        createdAt: now,
      ),
    );
    unawaited(_engine.process());
    return _toSummary(template);
  }

  @override
  Future<Template> createTemplate({
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    final now = DateTime.now().toUtc();
    final template = Template(
      id: _uuid.v4(),
      userId: _userId(),
      name: name.trim(),
      message: message,
      variables: variables,
      createdAt: now,
      updatedAt: now,
    );
    await _writeLocal(template);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.template,
        action: SyncAction.create,
        entityId: template.id,
        payload: template.toJson(),
        createdAt: now,
      ),
    );
    unawaited(_engine.process());
    return template;
  }

  @override
  Future<Template> updateTemplate({
    required String id,
    required String name,
    required String message,
    required List<String> variables,
  }) async {
    final current = await getById(id);
    final updated = current.copyWith(
      name: name.trim(),
      message: message,
      variables: variables,
      approvalStatus: TemplateApprovalStatus.draft,
      updatedAt: DateTime.now().toUtc(),
    );
    await _writeLocal(updated);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.template,
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
  Future<void> deleteTemplate(String id) async {
    final current = await getById(id);
    if (current.isDefault) {
      throw const TemplatesCannotDeleteDefaultFailure();
    }
    final clients = await _store.loadClients(_userId());
    if (clients.any((client) => client.templateId == id)) {
      throw const TemplatesInUseFailure();
    }
    final templates = await _store.loadTemplates(_userId());
    templates.removeWhere((template) => template.id == id);
    await _store.saveTemplates(_userId(), templates);
    await _queue.enqueue(
      SyncOperation(
        id: '',
        seq: 0,
        entity: SyncEntity.template,
        action: SyncAction.delete,
        entityId: id,
        payload: const {},
        createdAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(_engine.process());
  }

  @override
  Future<Template> submitForApproval(String id) async {
    if (!_connectivity.isOnline) {
      throw const TemplatesNetworkFailure();
    }
    return _remote.submitForApproval(id);
  }

  @override
  Future<Template> syncApprovalStatus(String id) async {
    if (!_connectivity.isOnline) {
      throw const TemplatesNetworkFailure();
    }
    return _remote.syncApprovalStatus(id);
  }

  Future<void> _writeLocal(Template template) async {
    final cached = await _store.loadTemplates(_userId());
    final next = [
      for (final item in cached)
        if (item.id != template.id) item,
      template,
    ];
    await _store.saveTemplates(_userId(), next);
  }

  TemplateSummary _toSummary(Template template) {
    return TemplateSummary(
      id: template.id,
      name: template.name,
      isDefault: template.isDefault,
      approvalStatus: template.approvalStatus,
    );
  }
}

List<Template> applyTemplateOps(
  List<Template> base,
  List<SyncOperation> ops,
) {
  final map = <String, Template>{
    for (final template in base) template.id: template,
  };
  for (final op in ops) {
    if (op.entity != SyncEntity.template) continue;
    switch (op.action) {
      case SyncAction.create:
      case SyncAction.update:
        map[op.entityId] = Template.fromJson(op.payload);
      case SyncAction.delete:
        map.remove(op.entityId);
      case SyncAction.setMessageSent:
        break;
    }
  }
  return map.values.toList();
}
