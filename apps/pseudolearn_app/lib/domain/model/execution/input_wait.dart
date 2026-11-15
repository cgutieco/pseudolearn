final class InputWait {
  final int resourceId;
  final int taskId;
  final int requestId;

  const InputWait({
    required this.resourceId,
    required this.taskId,
    required this.requestId,
  });

  bool matches(InputWait other) =>
      resourceId == other.resourceId &&
      taskId == other.taskId &&
      requestId == other.requestId;
}
