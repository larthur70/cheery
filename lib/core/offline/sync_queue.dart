import 'dart:async';

import 'package:cheery/core/offline/offline_database.dart';
import 'package:cheery/core/offline/sync_operation.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

/// Persistent FIFO outbox. Commands stay ordered until they reach Supabase.
class SyncQueue {
  SyncQueue(this._database);

  final OfflineDatabase _database;
  final _store = intMapStoreFactory.store('sync_queue');
  final _uuid = const Uuid();
  final _changes = StreamController<int>.broadcast();

  Stream<int> get pendingCount => _changes.stream;

  Future<int> get length async => (await list()).length;

  Future<List<SyncOperation>> list() async {
    final db = await _database.instance;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder(Field.key)]),
    );
    return [
      for (final record in records)
        SyncOperation.fromJson(Map<String, dynamic>.from(record.value)),
    ];
  }

  Future<void> enqueue(SyncOperation draft) async {
    final current = await list();
    final incoming = draft.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      seq: current.length,
    );
    final next = coalesceQueue(current, incoming);
    await _replaceAll(next);
  }

  Future<SyncOperation?> peek() async {
    final items = await list();
    if (items.isEmpty) return null;
    return items.first;
  }

  Future<void> remove(String id) async {
    final next = (await list()).where((op) => op.id != id).toList();
    await _replaceAll(next);
  }

  Future<void> clear() async {
    await _replaceAll(const []);
  }

  Future<void> _replaceAll(List<SyncOperation> ops) async {
    final db = await _database.instance;
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (var i = 0; i < ops.length; i++) {
        final op = ops[i].copyWith(seq: i);
        await _store.record(i + 1).put(txn, op.toJson());
      }
    });
    _changes.add(ops.length);
  }
}
