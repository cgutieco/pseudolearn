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
  cancelled,
  failed,
  limitReached,
}

final class RustBatch {
  final List<RustEvent> events;
  final RustTerminationKind termination;
  final String? failureCode;
  final String? failureMessage;

  const RustBatch({
    required this.events,
    required this.termination,
    this.failureCode,
    this.failureMessage,
  });

  factory RustBatch.fromJson(Map<String, Object?> json) {
    final termination = json['termination'] as Map<String, Object?>;
    final diagnostics = (json['diagnostics'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>();
    return RustBatch(
      events: (json['events'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(RustEvent.fromJson)
          .toList(growable: false),
      termination: _kindOf(termination['kind'] as String),
      failureCode: termination['code'] as String?,
      failureMessage: diagnostics.isEmpty
          ? null
          : diagnostics.last['message'] as String?,
    );
  }

  static RustTerminationKind _kindOf(String name) => switch (name) {
    'completed' => RustTerminationKind.completed,
    'awaiting_input' => RustTerminationKind.awaitingInput,
    'cancelled' => RustTerminationKind.cancelled,
    'failed' => RustTerminationKind.failed,
    'limit_reached' => RustTerminationKind.limitReached,
    _ => RustTerminationKind.running,
  };
}
