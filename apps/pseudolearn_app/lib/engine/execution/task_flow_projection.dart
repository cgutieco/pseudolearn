import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../../domain/ports/task_flow_projector.dart';
import 'task_flow_geometry.dart';

final class TaskFlowProjection implements TaskFlowProjector {
  const TaskFlowProjection();

  @override
  TaskFlowScene project({
    required List<ExecutionHistoryEvent> events,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) {
    final orderedEvents = TaskFlowGeometry.orderedEvents(events);
    final contentWidth = TaskFlowGeometry.contentWidth(
      width: width,
      start: rangeStart,
      end: rangeEnd,
    );
    final lanes = _lanes(TaskFlowGeometry.taskIds(orderedEvents));
    return TaskFlowScene(
      lanes: lanes.values.toList(),
      markers: _markers(
        events: orderedEvents,
        lanes: lanes,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        width: contentWidth,
      ),
      connectors: _connectors(
        events: orderedEvents,
        lanes: lanes,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        width: contentWidth,
      ),
      width: contentWidth,
      height: 56 + lanes.length * TaskFlowGeometry.laneSpacing,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  int? hitTest(TaskFlowScene scene, double x, double y) {
    for (final marker in scene.markers) {
      if ((marker.x - x).abs() <= 16 && (marker.y - y).abs() <= 16) {
        return marker.event.index;
      }
    }
    return null;
  }

  List<TaskFlowConnector> _connectors({
    required List<ExecutionHistoryEvent> events,
    required Map<int, TaskFlowLane> lanes,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) {
    final connectors = <TaskFlowConnector>[];
    for (final event in events) {
      if (event.index < rangeStart || event.index > rangeEnd) continue;
      final connector = _connectorFor(
        event: event,
        lanes: lanes,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        width: width,
      );
      if (connector != null) connectors.add(connector);
    }
    return connectors;
  }

  TaskFlowConnector? _connectorFor({
    required ExecutionHistoryEvent event,
    required Map<int, TaskFlowLane> lanes,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) => switch (event.eventClass) {
    'task_spawned' => _creationConnector(
      event: event,
      lanes: lanes,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      width: width,
    ),
    'task_suspended' => _waitConnector(
      event: event,
      lanes: lanes,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      width: width,
    ),
    _ => null,
  };

  TaskFlowConnector? _creationConnector({
    required ExecutionHistoryEvent event,
    required Map<int, TaskFlowLane> lanes,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) {
    final child = TaskFlowGeometry.integer(event.data['task']);
    final parent = TaskFlowGeometry.integer(event.data['parent']);
    if (child == null || parent == null || !lanes.containsKey(child)) {
      return null;
    }
    return _connector(
      event: event,
      startY: lanes[parent]?.y ?? lanes[child]!.y,
      endY: lanes[child]!.y,
      x: TaskFlowGeometry.eventX(
        event: event.index,
        start: rangeStart,
        end: rangeEnd,
        width: width,
      ),
      kind: 'creation',
      target: child,
    );
  }

  TaskFlowConnector? _waitConnector({
    required ExecutionHistoryEvent event,
    required Map<int, TaskFlowLane> lanes,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) {
    final cause = event.data['cause'];
    final target = TaskFlowGeometry.integer(event.data['target']);
    if (cause is! String || target == null) return null;
    final targetTask = cause == 'task' && lanes.containsKey(target)
        ? target
        : null;
    return _connector(
      event: event,
      startY: lanes[event.taskId]?.y ?? 32,
      endY: targetTask == null
          ? 32 + lanes.length * TaskFlowGeometry.laneSpacing
          : lanes[targetTask]!.y,
      x: TaskFlowGeometry.eventX(
        event: event.index,
        start: rangeStart,
        end: rangeEnd,
        width: width,
      ),
      kind: cause,
      target: target,
      targetTask: targetTask,
    );
  }

  TaskFlowConnector _connector({
    required ExecutionHistoryEvent event,
    required double startY,
    required double endY,
    required double x,
    required String kind,
    required int target,
    int? targetTask,
  }) => TaskFlowConnector(
    sourceEvent: event.index,
    sourceTaskId: event.taskId,
    targetTaskId: targetTask,
    targetKind: kind,
    targetId: target,
    cause: kind,
    startX: x,
    startY: startY,
    endX: x,
    endY: endY,
  );

  Map<int, TaskFlowLane> _lanes(List<int> taskIds) {
    final lanes = <int, TaskFlowLane>{};
    for (var order = 0; order < taskIds.length; order++) {
      final taskId = taskIds[order];
      lanes[taskId] = TaskFlowLane(
        taskId: taskId,
        order: order,
        y: 32 + order * TaskFlowGeometry.laneSpacing,
      );
    }
    return lanes;
  }

  List<TaskFlowMarker> _markers({
    required List<ExecutionHistoryEvent> events,
    required Map<int, TaskFlowLane> lanes,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  }) => [
    for (final event in events)
      if (event.index >= rangeStart && event.index <= rangeEnd)
        TaskFlowMarker(
          event: event,
          x: TaskFlowGeometry.eventX(
            event: event.index,
            start: rangeStart,
            end: rangeEnd,
            width: width,
          ),
          y: lanes[event.taskId]!.y,
        ),
  ];
}
