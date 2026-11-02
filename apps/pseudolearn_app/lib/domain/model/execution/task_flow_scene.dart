import 'execution_history_event.dart';

final class TaskFlowLane {
  final int taskId;
  final int order;
  final double y;

  const TaskFlowLane({
    required this.taskId,
    required this.order,
    required this.y,
  });
}

final class TaskFlowMarker {
  final ExecutionHistoryEvent event;
  final double x;
  final double y;

  const TaskFlowMarker({required this.event, required this.x, required this.y});
}

final class TaskFlowConnector {
  final int sourceEvent;
  final int sourceTaskId;
  final int? targetTaskId;
  final String targetKind;
  final int targetId;
  final String cause;
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  const TaskFlowConnector({
    required this.sourceEvent,
    required this.sourceTaskId,
    required this.targetTaskId,
    required this.targetKind,
    required this.targetId,
    required this.cause,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}

final class TaskFlowScene {
  final List<TaskFlowLane> lanes;
  final List<TaskFlowMarker> markers;
  final List<TaskFlowConnector> connectors;
  final double width;
  final double height;
  final int rangeStart;
  final int rangeEnd;

  TaskFlowScene({
    required List<TaskFlowLane> lanes,
    required List<TaskFlowMarker> markers,
    required List<TaskFlowConnector> connectors,
    required this.width,
    required this.height,
    required this.rangeStart,
    required this.rangeEnd,
  }) : lanes = List.unmodifiable(lanes),
       markers = List.unmodifiable(markers),
       connectors = List.unmodifiable(connectors);
}
