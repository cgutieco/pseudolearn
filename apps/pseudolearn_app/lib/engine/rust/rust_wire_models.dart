import 'rust_event_classes.dart';

final class RustEventSourceIdentity {
  final String projectId;
  final String revisionId;
  final int sourceId;

  const RustEventSourceIdentity({
    required this.projectId,
    required this.revisionId,
    required this.sourceId,
  });

  factory RustEventSourceIdentity.fromJson(Map<String, Object?> json) {
    final projectId = json['project_id'];
    final revisionId = json['revision_id'];
    final sourceId = json['source_id'];
    if (projectId is! String ||
        revisionId is! String ||
        sourceId is! int ||
        projectId.isEmpty ||
        revisionId.isEmpty ||
        sourceId <= 0) {
      throw const FormatException('Invalid event source identity');
    }
    return RustEventSourceIdentity(
      projectId: projectId,
      revisionId: revisionId,
      sourceId: sourceId,
    );
  }
}

final class RustEvent {
  final String eventClass;
  final int line;
  final int depth;
  final Map<String, Object?> data;
  final String? sourceRevisionId;
  final RustEventSourceIdentity? sourceIdentity;
  final String? nodeId;
  final int? taskId;

  const RustEvent({
    required this.eventClass,
    required this.line,
    required this.depth,
    required this.data,
    this.sourceRevisionId,
    this.sourceIdentity,
    this.nodeId,
    this.taskId,
  });

  factory RustEvent.fromJson(Map<String, Object?> json) {
    final source = json['source'];
    final data = json['data'];
    final eventClass = json['class'] as String;
    if (!rustKnownEventClass(eventClass)) {
      throw FormatException('Unknown event class: $eventClass');
    }
    if (source != null && source is! Map<String, Object?>) {
      throw const FormatException('Invalid event source');
    }
    if (data != null && data is! Map<String, Object?>) {
      throw const FormatException('Invalid event data');
    }
    final sourceFields = source as Map<String, Object?>?;
    final sourceRevisionId = sourceFields?['revision_id'];
    final sourceNodeId = sourceFields?['node_id'];
    final identity = sourceFields?['identity'];
    final taskId = json['task_id'];
    if ((sourceFields != null &&
            (sourceRevisionId is! String || sourceNodeId is! String)) ||
        (sourceNodeId != null && sourceNodeId is! String) ||
        (identity != null && identity is! Map<String, Object?>) ||
        (taskId != null && (taskId is! int || taskId < 0))) {
      throw const FormatException('Invalid event source identity');
    }
    final event = RustEvent(
      eventClass: eventClass,
      line: json['line'] as int,
      depth: json['depth'] as int,
      data: data as Map<String, Object?>? ?? const {},
      sourceRevisionId: sourceRevisionId as String?,
      sourceIdentity: identity == null
          ? null
          : RustEventSourceIdentity.fromJson(identity as Map<String, Object?>),
      nodeId: sourceNodeId as String?,
      taskId: taskId as int?,
    );
    RustTaskEvent.tryFrom(event);
    return event;
  }
}

enum RustTerminationKind {
  running,
  completed,
  awaitingInput,
  awaitingEffect,
  cancelled,
  failed,
  limitReached,
}

final class PendingEffectRequest {
  final int effectSeq;
  final String capabilityKind;
  final String operation;
  final String argumentsSummary;
  final int? sourceNodeId;
  final int taskId;

  const PendingEffectRequest({
    required this.effectSeq,
    required this.capabilityKind,
    required this.operation,
    required this.argumentsSummary,
    this.sourceNodeId,
    this.taskId = 0,
  });

  factory PendingEffectRequest.fromJson(Map<String, Object?> json) =>
      PendingEffectRequest(
        effectSeq: (json['effect_seq'] as num?)?.toInt() ?? 0,
        capabilityKind: (json['capability_kind'] as String?) ?? '',
        operation: (json['operation'] as String?) ?? '',
        argumentsSummary: (json['arguments_summary'] as String?) ?? '',
        sourceNodeId: (json['source_node_id'] as num?)?.toInt(),
        taskId: (json['task_id'] as num?)?.toInt() ?? 0,
      );
}

final class RustBatch {
  final List<RustEvent> events;
  final RustTerminationKind termination;
  final String? failureCode;
  final String? failureMessage;
  final PendingEffectRequest? pendingEffect;
  final Map<String, Object?>? pendingRequest;
  final List<PendingEffectRequest> pendingEffects;

  const RustBatch({
    required this.events,
    required this.termination,
    this.failureCode,
    this.failureMessage,
    this.pendingEffect,
    this.pendingRequest,
    this.pendingEffects = const [],
  });

  factory RustBatch.fromJson(Map<String, Object?> json) {
    final termination = json['termination'] as Map<String, Object?>;
    final diagnostics = (json['diagnostics'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>();
    final kind = _kindOf(termination['kind'] as String);
    return RustBatch(
      events: (json['events'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(RustEvent.fromJson)
          .toList(growable: false),
      termination: kind,
      failureCode: termination['code'] as String?,
      failureMessage: diagnostics.isEmpty
          ? null
          : diagnostics.last['message'] as String?,
      pendingEffect: kind == RustTerminationKind.awaitingEffect
          ? PendingEffectRequest.fromJson(termination)
          : null,
      pendingRequest: json['pending_effect'] as Map<String, Object?>?,
      pendingEffects: [
        for (final pending
            in (json['pending_effects'] as List<Object?>? ?? const [])
                .cast<Map<String, Object?>>())
          PendingEffectRequest.fromJson(pending),
      ],
    );
  }

  static RustTerminationKind _kindOf(String name) => switch (name) {
    'completed' => RustTerminationKind.completed,
    'awaiting_input' => RustTerminationKind.awaitingInput,
    'awaiting_effect' => RustTerminationKind.awaitingEffect,
    'cancelled' => RustTerminationKind.cancelled,
    'failed' => RustTerminationKind.failed,
    'limit_reached' => RustTerminationKind.limitReached,
    _ => RustTerminationKind.running,
  };
}
