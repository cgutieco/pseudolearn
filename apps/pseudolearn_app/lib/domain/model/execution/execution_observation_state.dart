final class ExecutionObservedTask {
  final int taskId;
  final String name;
  final String state;

  const ExecutionObservedTask({
    required this.taskId,
    required this.name,
    required this.state,
  });
}

final class ExecutionObservedFrame {
  final int id;
  final String name;
  final int sourceId;
  final String? revisionId;
  final int line;
  final int column;

  const ExecutionObservedFrame({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.revisionId,
    required this.line,
    required this.column,
  });
}

final class ExecutionObservationState {
  final int event;
  final int taskId;
  final int totalFrames;
  final List<ExecutionObservedFrame> frames;
  final List<ExecutionObservedTask> tasks;

  ExecutionObservationState({
    required this.event,
    required this.taskId,
    required this.totalFrames,
    required List<ExecutionObservedFrame> frames,
    required List<ExecutionObservedTask> tasks,
  }) : frames = List.unmodifiable(frames),
       tasks = List.unmodifiable(tasks);
}
