import 'package:cheery/core/offline/sync_operation.dart';
import 'package:flutter_test/flutter_test.dart';

SyncOperation _op({
  required SyncAction action,
  String entityId = 'c1',
  Map<String, dynamic> payload = const {'name': 'A'},
  String id = 'op',
}) {
  return SyncOperation(
    id: id,
    seq: 0,
    entity: SyncEntity.client,
    action: action,
    entityId: entityId,
    payload: payload,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('coalesceQueue', () {
    test('merges update into a pending local create', () {
      final queued = [_op(action: SyncAction.create, id: '1')];
      final next = coalesceQueue(
        queued,
        _op(
          action: SyncAction.update,
          id: '2',
          payload: {'name': 'B', 'phone': '1'},
        ),
      );

      expect(next, hasLength(1));
      expect(next.single.action, SyncAction.create);
      expect(next.single.payload['name'], 'B');
      expect(next.single.payload['phone'], '1');
    });

    test('drops create + delete of an entity that never reached the server', () {
      final queued = [_op(action: SyncAction.create, id: '1')];
      final next = coalesceQueue(
        queued,
        _op(action: SyncAction.delete, id: '2'),
      );

      expect(next, isEmpty);
    });

    test('keeps delete of a server entity and drops pending updates', () {
      final queued = [
        _op(action: SyncAction.update, id: '1', payload: {'name': 'B'}),
      ];
      final next = coalesceQueue(
        queued,
        _op(action: SyncAction.delete, id: '2'),
      );

      expect(next, hasLength(1));
      expect(next.single.action, SyncAction.delete);
    });

    test('merges successive updates for the same entity', () {
      final queued = [
        _op(action: SyncAction.update, id: '1', payload: {'name': 'A'}),
      ];
      final next = coalesceQueue(
        queued,
        _op(action: SyncAction.update, id: '2', payload: {'phone': '99'}),
      );

      expect(next, hasLength(1));
      expect(next.single.payload['name'], 'A');
      expect(next.single.payload['phone'], '99');
    });

    test('preserves order across different entities', () {
      final queued = [
        _op(action: SyncAction.create, entityId: 'a', id: '1'),
      ];
      final next = coalesceQueue(
        queued,
        _op(action: SyncAction.create, entityId: 'b', id: '2'),
      );

      expect(next.map((op) => op.entityId), ['a', 'b']);
    });
  });
}
