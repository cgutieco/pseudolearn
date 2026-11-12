import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/task_event_kind.dart';
import 'package:pseudolearn_app/domain/model/execution/task_flow_scene.dart';
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

  test('links creation and a task wait to the target column', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 7, 'parent': 0, 'scope': 11}),
        _event(1, 7, 'task_suspended', {
          'task': 7,
          'cause': 'task',
          'target': 2,
        }),
        _event(2, 2, 'task_ready', {'task': 2, 'cause': 'spawn'}),
      ],
      rangeStart: 0,
      rangeEnd: 2,
    );

    expect(scene.columns.map((column) => column.taskId), [0, 2, 7]);
    expect(scene.rows.map((row) => row.kind), [
      TaskEventKind.spawn,
      TaskEventKind.suspend,
      TaskEventKind.ready,
    ]);
    expect(scene.rows.first.linkKind, TaskFlowLinkKind.creation);
    expect(scene.rows.first.linkedColumns, [2]);
    expect(scene.rows[1].waitCause, TaskWaitCause.task);
    expect(scene.rows[1].relatedTaskId, 2);
    expect(scene.rows[1].linkedColumns, [1]);
  });

  test('a join wait points at the children of that scope only', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 0}),
        _event(1, 0, 'task_spawned', {'task': 2, 'parent': 0, 'scope': 0}),
        _event(2, 0, 'task_spawned', {'task': 3, 'parent': 0, 'scope': 5}),
        _event(3, 0, 'task_suspended', {
          'task': 0,
          'cause': 'join',
          'target': 0,
        }),
      ],
      rangeStart: 0,
      rangeEnd: 3,
    );

    final wait = scene.rows.last;
    expect(wait.waitCause, TaskWaitCause.join);
    expect(wait.linkKind, TaskFlowLinkKind.wait);
    expect(wait.linkedColumns, [1, 2]);
    expect(wait.relatedTaskId, isNull);
  });

  test('channel waits keep the channel and draw no cross-lane link', () {
    final scene = projection.project(
      events: [
        _event(0, 1, 'task_suspended', {
          'task': 1,
          'cause': 'channel_send',
          'target': 4,
        }),
        _event(1, 2, 'channel_received', {'channel': 4, 'present': false}),
      ],
      rangeStart: 0,
      rangeEnd: 1,
    );

    expect(scene.rows.first.waitCause, TaskWaitCause.channelSend);
    expect(scene.rows.first.channelId, 4);
    expect(scene.rows.first.linkedColumns, isEmpty);
    expect(scene.rows.last.kind, TaskEventKind.channelEmpty);
  });

  test('lifecycle rows belong to their subject and names come from calls', () {
    final scene = projection.project(
      events: [
        _event(0, 2, 'task_ready', {'task': 1, 'cause': 'channel'}),
        _event(1, 1, 'call', {'nombre': 'Produce'}),
        _event(2, 1, 'call', {'nombre': 'Helper'}),
        _event(3, 0, 'call', {'nombre': 'Main'}),
      ],
      rangeStart: 0,
      rangeEnd: 3,
    );

    expect(scene.rows.first.taskId, 1);
    expect(scene.nameOf(1), 'Produce');
    expect(scene.nameOf(0), isNull);
    expect(scene.rows[1].detail, 'Produce');
  });

  test('orders out-of-order input, clips to the range and finds rows', () {
    final scene = projection.project(
      events: [
        _event(3, 0, 'statement_entered'),
        _event(1, 0, 'statement_entered'),
        _event(2, 0, 'statement_exited'),
        _event(0, 0, 'statement_entered'),
      ],
      rangeStart: 1,
      rangeEnd: 2,
    );
    final empty = projection.project(
      events: const [],
      rangeStart: 0,
      rangeEnd: -1,
    );

    expect(scene.rows.map((row) => row.event.index), [1, 2]);
    expect(scene.rowIndexOf(2), 1);
    expect(scene.rowIndexOf(3), isNull);
    expect(scene.rowOf(0), isNull);
    expect(empty.rows, isEmpty);
    expect(empty.columns.map((column) => column.taskId), [0]);
  });
}
