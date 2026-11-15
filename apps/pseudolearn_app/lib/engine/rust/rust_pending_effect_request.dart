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
