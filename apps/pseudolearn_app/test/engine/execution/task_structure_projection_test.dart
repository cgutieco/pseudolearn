import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/block_position.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/task_event_kind.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';

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
  const projection = TaskStructureProjection();

  test('projects nested parent scopes and assigns joins to their owner', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 4, 'parent': 0, 'scope': 12}),
        _event(1, 4, 'task_spawned', {'task': 2, 'parent': 4, 'scope': 19}),
        _event(2, 4, 'task_suspended', {
          'task': 4,
          'cause': 'task',
          'target': 2,
        }),
        _event(3, 4, 'scope_joined', {'task': 4, 'outcome': 'success'}),
        _event(4, 2, 'task_completed', {'task': 2, 'outcome': 'success'}),
      ],
      horizonFirst: 0,
    );

    expect(scene.tasks.map((task) => task.taskId), [0, 4, 2]);
    expect(scene.tasks.map((task) => task.depth), [0, 1, 2]);
    expect(scene.tasks[2].parentId, 4);
    expect(scene.tasks[2].scopeId, 19);
    expect(scene.tasks[1].children, [2]);
    expect(scene.tasks[1].joins.single.eventIndex, 3);
    expect(scene.tasks[2].status, 'completed');
    expect(scene.tasks[1].status, 'suspended');
    expect(scene.beginsAtRetentionHorizon, isFalse);
  });

  test('reports an incomplete retained tree and ignores unowned records', () {
    final scene = projection.project(
      events: [
        _event(8, 5, 'task_spawned', {'task': 9, 'parent': 5, 'scope': 33}),
        _event(9, 5, 'scope_joined', {'outcome': 'success'}),
        _event(10, 5, 'task_completed', {'task': 5, 'outcome': 'success'}),
      ],
      horizonFirst: 8,
    );

    expect(scene.beginsAtRetentionHorizon, isTrue);
    expect(scene.tasks.map((task) => task.taskId), [0, 9]);
    expect(scene.tasks.last.parentId, isNull);
    expect(scene.tasks.every((task) => task.joins.isEmpty), isTrue);
    expect(scene.tasks.last.status, 'created');
  });

  test('projects the state at the selected event, not the live one', () {
    final events = [
      _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 0}),
      _event(1, 0, 'task_ready', {'task': 1, 'cause': 'spawn'}),
      _event(2, 0, 'task_suspended', {'task': 0, 'cause': 'join', 'target': 0}),
      _event(3, 1, 'task_resumed', {'task': 1}),
      _event(4, 1, 'statement_entered'),
      _event(5, 1, 'task_completed', {'task': 1, 'outcome': 'success'}),
    ];
    final live = [
      _context(0, ExecutionTaskStatus.completed, 'success'),
      _context(1, ExecutionTaskStatus.completed, 'success'),
    ];

    final past = projection.project(
      events: events,
      horizonFirst: 0,
      selectedEvent: 2,
      liveEvent: 5,
      taskContexts: live,
    );
    final running = projection.project(
      events: events,
      horizonFirst: 0,
      selectedEvent: 4,
      liveEvent: 5,
      taskContexts: live,
    );

    expect(past.tasks.map((task) => task.status), ['suspended', 'ready']);
    expect(past.tasks.first.wait?.cause, TaskWaitCause.join);
    expect(past.tasks.first.wait?.pendingChildren, 1);
    expect(past.tasks.first.wait?.totalChildren, 1);
    expect(running.tasks.last.status, 'running');
    expect(running.tasks.last.currentLine, 5);
    expect(past.nameOf(7), isNull);
  });

  test('a task wait names its target and clears when the task resumes', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 0}),
        _event(1, 1, 'call', {'nombre': 'Worker'}),
        _event(2, 0, 'task_suspended', {'task': 0, 'cause': 'task', 'target': 1}),
        _event(3, 0, 'task_resumed', {'task': 0}),
      ],
      horizonFirst: 0,
      selectedEvent: 2,
      liveEvent: 3,
    );
    final resumed = projection.project(
      events: [
        _event(2, 0, 'task_suspended', {'task': 0, 'cause': 'task', 'target': 1}),
        _event(3, 0, 'task_resumed', {'task': 0}),
      ],
      horizonFirst: 0,
    );

    expect(scene.tasks.first.wait?.cause, TaskWaitCause.task);
    expect(scene.tasks.first.wait?.target, 1);
    expect(scene.nameOf(1), 'Worker');
    expect(resumed.tasks.single.wait, isNull);
    expect(resumed.tasks.single.status, 'running');
  });

  test('empty history retains only the root task', () {
    final scene = projection.project(events: const [], horizonFirst: 0);

    expect(scene.tasks, hasLength(1));
    expect(scene.tasks.single.taskId, 0);
    expect(scene.tasks.single.joins, isEmpty);
  });

  test('distinguishes recoverable errors from cooperative cancellation', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 2}),
        _event(1, 1, 'task_completed', {'task': 1, 'outcome': 'error'}),
        _event(2, 0, 'task_spawned', {'task': 2, 'parent': 0, 'scope': 2}),
        _event(3, 2, 'task_completed', {'task': 2, 'outcome': 'cancelled'}),
      ],
      horizonFirst: 0,
    );

    expect(scene.tasks[1].status, 'completed');
    expect(scene.tasks[1].outcome, 'error');
    expect(scene.tasks[2].status, 'cancelled');
    expect(scene.tasks[2].outcome, 'cancelled');
  });

  test('applies global trap states by task identity', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 2}),
        _event(1, 0, 'task_spawned', {'task': 2, 'parent': 0, 'scope': 2}),
      ],
      horizonFirst: 0,
      taskContexts: [
        _context(0, ExecutionTaskStatus.failed, 'division_by_zero'),
        _context(1, ExecutionTaskStatus.interruptedByFailure),
        _context(2, ExecutionTaskStatus.failed),
      ],
    );

    expect(scene.tasks.map((task) => task.status), [
      'failed',
      'interruptedByFailure',
      'failed',
    ]);
    expect(scene.tasks.first.outcome, 'division_by_zero');
    expect(scene.tasks[1].completedAtEvent, isNull);
  });

  test('applies host cancellation without inventing completion events', () {
    final scene = projection.project(
      events: [
        _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 2}),
      ],
      horizonFirst: 0,
      taskContexts: [
        _context(0, ExecutionTaskStatus.cancelledByHost, 'cancelled_by_host'),
        _context(1, ExecutionTaskStatus.interruptedByHost),
      ],
    );

    expect(scene.tasks.map((task) => task.status), [
      'cancelledByHost',
      'interruptedByHost',
    ]);
    expect(scene.tasks.every((task) => task.completedAtEvent == null), isTrue);
  });

  test(
    'lifecycle state follows event order even when the input list does not',
    () {
      final scene = projection.project(
        events: [
          _event(2, 3, 'task_completed', {'task': 3, 'outcome': 'success'}),
          _event(0, 0, 'task_spawned', {'task': 3, 'parent': 0, 'scope': 4}),
          _event(1, 3, 'task_ready', {'task': 3}),
        ],
        horizonFirst: 0,
      );

      expect(scene.tasks.last.status, 'completed');
      expect(scene.tasks.last.completedAtEvent, 2);
    },
  );
}

ExecutionTaskContext _context(
  int taskId,
  ExecutionTaskStatus status, [
  String? outcome,
]) => ExecutionTaskContext(
  taskId: taskId,
  status: status,
  completionOutcome: outcome,
  lastEventIndex: 1,
  focus: null,
  focusRevision: 0,
  blockPosition: const BlockPosition.outermost(),
  frames: const [],
  scopeName: 'global',
  scopeDepth: taskId == 0 ? 1 : 0,
  variables: const [],
);
