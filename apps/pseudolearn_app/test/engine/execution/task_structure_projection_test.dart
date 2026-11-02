import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
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

    expect(scene.tasks.map((task) => task.taskId), [0, 2, 4]);
    expect(scene.tasks[1].parentId, 4);
    expect(scene.tasks[1].scopeId, 19);
    expect(scene.tasks[2].children, [2]);
    expect(scene.tasks[2].joins.single.eventIndex, 3);
    expect(scene.tasks[1].status, 'completed');
    expect(scene.tasks[2].status, 'suspended');
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

  test('empty history retains only the root task', () {
    final scene = projection.project(events: const [], horizonFirst: 0);

    expect(scene.tasks, hasLength(1));
    expect(scene.tasks.single.taskId, 0);
    expect(scene.tasks.single.joins, isEmpty);
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
