import '../../domain/model/execution/input_wait.dart';

final class PendingInputRequest {
  final int resourceId;
  final int requestId;
  final int taskId;

  const PendingInputRequest({
    required this.resourceId,
    required this.requestId,
    required this.taskId,
  });

  factory PendingInputRequest.fromJson(Map<String, Object?> json) {
    final resourceId = json['resource_id'];
    final requestId = json['request_id'];
    final taskId = json['task_id'];
    if (resourceId is! int ||
        resourceId <= 0 ||
        requestId is! int ||
        requestId <= 0 ||
        taskId is! int ||
        taskId < 0) {
      throw const FormatException('Invalid input request identity');
    }
    return PendingInputRequest(
      resourceId: resourceId,
      requestId: requestId,
      taskId: taskId,
    );
  }

  InputWait toDomain() =>
      InputWait(resourceId: resourceId, requestId: requestId, taskId: taskId);
}
