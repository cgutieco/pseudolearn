final class RustEvent {
  final String eventClass;
  final int line;
  final int depth;
  final Map<String, Object?> data;
  final String? nodeId;

  const RustEvent({
    required this.eventClass,
    required this.line,
    required this.depth,
    required this.data,
    required this.nodeId,
  });

  factory RustEvent.fromJson(Map<String, Object?> json) {
    final source = json['source'];
    final data = json['data'];
    return RustEvent(
      eventClass: json['class'] as String,
      line: json['line'] as int,
      depth: json['depth'] as int,
      data: data is Map<String, Object?> ? data : const {},
      nodeId: source is Map<String, Object?>
          ? source['node_id'] as String?
          : null,
    );
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

  const PendingEffectRequest({
    required this.effectSeq,
    required this.capabilityKind,
    required this.operation,
    required this.argumentsSummary,
    this.sourceNodeId,
  });

  factory PendingEffectRequest.fromJson(Map<String, Object?> json) =>
      PendingEffectRequest(
        effectSeq: (json['effect_seq'] as num?)?.toInt() ?? 0,
        capabilityKind: (json['capability_kind'] as String?) ?? '',
        operation: (json['operation'] as String?) ?? '',
        argumentsSummary: (json['arguments_summary'] as String?) ?? '',
        sourceNodeId: (json['source_node_id'] as num?)?.toInt(),
      );
}

final class RustBatch {
  final List<RustEvent> events;
  final RustTerminationKind termination;
  final String? failureCode;
  final String? failureMessage;
  final PendingEffectRequest? pendingEffect;
  final Map<String, Object?>? pendingRequest;

  const RustBatch({
    required this.events,
    required this.termination,
    this.failureCode,
    this.failureMessage,
    this.pendingEffect,
    this.pendingRequest,
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
