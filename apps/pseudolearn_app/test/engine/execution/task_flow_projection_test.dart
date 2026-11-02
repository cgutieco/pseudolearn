import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';

ExecutionHistoryEvent _event(
  int index,
  int taskId,
  String eventClass, [
  Map<String, Object?> data = const {},
]) => ExecutionHistoryEvent(
  index: index,
  taskId: taskId,
  eventClass: eventClass,
  line: index + 1,
  depth: 0,
  data: data,
  revisionId: null,
  nodeId: null,
  sourceRange: null,
);

void main() {
  const projection = TaskFlowProjection();

  test('orders lanes and links task creation and wait cause to targets', () {
    final events = [
      _event(0, 0, 'task_spawned', {'task': 7, 'parent': 0, 'scope': 11}),
      _event(1, 7, 'task_suspended', {'task': 7, 'cause': 'task', 'target': 2}),
      _event(2, 2, 'task_ready', {'task': 2}),
    ];

    final scene = projection.project(
      events: events,
      rangeStart: 0,
      rangeEnd: 2,
      width: 240,
    );

    expect(scene.lanes.map((lane) => lane.taskId), [0, 2, 7]);
    expect(scene.markers.map((marker) => marker.event.index), [0, 1, 2]);
    expect(scene.connectors.map((connector) => connector.targetKind), [
      'creation',
      'task',
    ]);
    expect(scene.connectors.last.targetTaskId, 2);
  });

  test('hit testing selects a marker and rejects empty space', () {
    final scene = projection.project(
      events: [_event(4, 0, 'statement')],
      rangeStart: 4,
      rangeEnd: 4,
      width: 320,
    );
    final marker = scene.markers.single;

    expect(projection.hitTest(scene, marker.x, marker.y), 4);
    expect(projection.hitTest(scene, 0, 0), isNull);
  });

  test('projection order stays stable when events arrive out of order', () {
    final events = [
      _event(3, 8, 'task_ready'),
      _event(1, 2, 'task_spawned', {'task': 8, 'parent': 2, 'scope': 5}),
      _event(2, 8, 'task_suspended', {'task': 8, 'cause': 'task', 'target': 2}),
    ];
    final scene = projection.project(
      events: events,
      rangeStart: 1,
      rangeEnd: 3,
      width: 240,
    );

    expect(scene.markers.map((marker) => marker.event.index), [1, 2, 3]);
    expect(scene.connectors.map((connector) => connector.sourceEvent), [1, 2]);
  });

  test('clips markers to the selected event range and handles empty input', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'statement'),
        _event(1, 0, 'statement'),
        _event(2, 0, 'statement'),
      ],
      rangeStart: 1,
      rangeEnd: 1,
      width: 120,
    );
    final empty = projection.project(
      events: const [],
      rangeStart: 0,
      rangeEnd: -1,
      width: 120,
    );

    expect(scene.markers.map((marker) => marker.event.index), [1]);
    expect(scene.width, greaterThan(120));
    expect(empty.markers, isEmpty);
    expect(empty.lanes.map((lane) => lane.taskId), [0]);
  });
}
