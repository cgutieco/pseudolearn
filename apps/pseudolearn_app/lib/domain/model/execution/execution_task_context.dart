import 'block_position.dart';
import 'execution_focus.dart';
import 'execution_stack_frame.dart';
import 'watch_row.dart';

enum ExecutionTaskStatus {
  created,
  ready,
  running,
  suspended,
  cancellationRequested,
  completed,
  failed,
  cancelled,
  cancelledByHost,
  interruptedByFailure,
  interruptedByHost,
  limitReached,
  interruptedByLimit;

  bool get isTerminal => switch (this) {
    created || ready || running || suspended || cancellationRequested => false,
    completed ||
    failed ||
    cancelled ||
    cancelledByHost ||
    interruptedByFailure ||
    interruptedByHost ||
    limitReached ||
    interruptedByLimit => true,
  };
}

final class ExecutionTaskContext {
  final int taskId;
  final ExecutionTaskStatus status;
  final String? completionOutcome;
  final int lastEventIndex;
  final ExecutionFocus? focus;
  final int focusRevision;
  final BlockPosition blockPosition;
  final List<ExecutionStackFrame> frames;
  final String scopeName;
  final int scopeDepth;
  final List<WatchRow> variables;

  ExecutionTaskContext({
    required this.taskId,
    required this.status,
    required this.completionOutcome,
    required this.lastEventIndex,
    required this.focus,
    required this.focusRevision,
    required this.blockPosition,
    required List<ExecutionStackFrame> frames,
    required this.scopeName,
    required this.scopeDepth,
    required List<WatchRow> variables,
  }) : frames = List.unmodifiable(frames),
       variables = List.unmodifiable(variables);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionTaskContext &&
          taskId == other.taskId &&
          status == other.status &&
          completionOutcome == other.completionOutcome &&
          lastEventIndex == other.lastEventIndex &&
          focus == other.focus &&
          focusRevision == other.focusRevision &&
          blockPosition == other.blockPosition &&
          _sameList(frames, other.frames) &&
          scopeName == other.scopeName &&
          scopeDepth == other.scopeDepth &&
          _sameVariables(variables, other.variables);

  @override
  int get hashCode => Object.hash(
    taskId,
    status,
    completionOutcome,
    lastEventIndex,
    focus,
    focusRevision,
    blockPosition,
    Object.hashAll(frames),
    scopeName,
    scopeDepth,
    Object.hashAll(variables.map(_variableHash)),
  );
}

bool _sameList<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _sameVariables(List<WatchRow> left, List<WatchRow> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    final first = left[index];
    final second = right[index];
    if (first.name != second.name ||
        first.formattedValue != second.formattedValue ||
        first.identityBadge != second.identityBadge ||
        first.scopeName != second.scopeName ||
        first.isAbsent != second.isAbsent) {
      return false;
    }
  }
  return true;
}

int _variableHash(WatchRow row) => Object.hash(
  row.name,
  row.formattedValue,
  row.identityBadge,
  row.scopeName,
  row.isAbsent,
);
