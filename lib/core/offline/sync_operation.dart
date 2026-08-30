enum SyncEntity { client, template, profile, reminder }

enum SyncAction { create, update, delete, setMessageSent }

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.seq,
    required this.entity,
    required this.action,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final int seq;
  final SyncEntity entity;
  final SyncAction action;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  SyncOperation copyWith({
    String? id,
    int? seq,
    SyncEntity? entity,
    SyncAction? action,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seq': seq,
        'entity': entity.name,
        'action': action.name,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      entity: SyncEntity.values.byName(json['entity'] as String),
      action: SyncAction.values.byName(json['action'] as String),
      entityId: json['entityId'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Keeps the outbox ordered and collapses redundant ops for the same entity.
List<SyncOperation> coalesceQueue(
  List<SyncOperation> queue,
  SyncOperation incoming,
) {
  bool sameTarget(SyncOperation op) =>
      op.entity == incoming.entity && op.entityId == incoming.entityId;

  if (incoming.action == SyncAction.delete) {
    final hadLocalCreate = queue.any(
      (op) => sameTarget(op) && op.action == SyncAction.create,
    );
    final withoutTarget = queue.where((op) => !sameTarget(op)).toList();
    if (hadLocalCreate) return withoutTarget;
    return [...withoutTarget, incoming];
  }

  if (incoming.action == SyncAction.create) {
    return [...queue, incoming];
  }

  final createIndex = queue.indexWhere(
    (op) => sameTarget(op) && op.action == SyncAction.create,
  );
  if (createIndex >= 0) {
    final current = queue[createIndex];
    final merged = current.copyWith(
      payload: {...current.payload, ...incoming.payload},
    );
    return [
      ...queue.sublist(0, createIndex),
      merged,
      ...queue.sublist(createIndex + 1),
    ];
  }

  final lastMutateIndex = queue.lastIndexWhere(
    (op) =>
        sameTarget(op) &&
        (op.action == SyncAction.update ||
            op.action == SyncAction.setMessageSent),
  );
  if (lastMutateIndex >= 0) {
    final current = queue[lastMutateIndex];
    final merged = current.copyWith(
      action: incoming.action == SyncAction.update
          ? SyncAction.update
          : current.action,
      payload: {...current.payload, ...incoming.payload},
    );
    return [
      ...queue.sublist(0, lastMutateIndex),
      merged,
      ...queue.sublist(lastMutateIndex + 1),
    ];
  }

  return [...queue, incoming];
}
