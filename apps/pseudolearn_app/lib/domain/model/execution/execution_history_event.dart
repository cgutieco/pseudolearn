import '../analysis/source_range.dart';

final class ExecutionHistoryEvent {
  final int index;
  final int taskId;
  final String eventClass;
  final int line;
  final int depth;
  final Map<String, Object?> data;
  final String? revisionId;
  final String? nodeId;
  final SourceRange? sourceRange;

  ExecutionHistoryEvent({
    required this.index,
    required this.taskId,
    required this.eventClass,
    required this.line,
    required this.depth,
    required Map<String, Object?> data,
    required this.revisionId,
    required this.nodeId,
    required this.sourceRange,
  }) : data = Map.unmodifiable(data);
}
