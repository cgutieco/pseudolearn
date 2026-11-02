import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_history_command.dart';
import 'package:pseudolearn_app/application/execution/execution_history_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_history_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_value_page.dart';
import 'package:pseudolearn_app/domain/ports/program_execution_observer.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';

void main() {
  group('ExecutionHistoryCubit', () {
    late StreamController<ExecutionState> executionStates;
    late _FakeObserver observer;
    late ExecutionHistoryCubit cubit;

    setUp(() {
      executionStates = StreamController<ExecutionState>.broadcast(sync: true);
      observer = _FakeObserver(events: _events(10));
      cubit = _cubit(executionStates.stream, observer);
    });

    tearDown(() async {
      await cubit.close();
      await executionStates.close();
    });

    test(
      'keeps selected ranges and task state independent from live execution',
      () {
        executionStates.add(_executionState(1, -1));
        executionStates.add(_executionState(1, 5));
        cubit.dispatch(const SelectHistoryEvent(4));
        final selectedRange = (cubit.state.rangeStart, cubit.state.rangeEnd);
        executionStates.add(_executionState(1, 6));

        expect(cubit.state.liveEvent, 6);
        expect(cubit.state.selectedEvent, 4);
        expect((cubit.state.rangeStart, cubit.state.rangeEnd), selectedRange);
        expect(cubit.state.events.last.index, 6);
        expect(cubit.state.events.last.index, lessThan(observer.horizonLast));

        cubit.dispatch(
          const SelectHistorySurface(ExecutionHistorySurface.events),
        );
        cubit.dispatch(const SelectHistoryTask(1));

        expect(cubit.state.liveEvent, 6);
        expect(cubit.state.selectedEvent, 4);
        expect(observer.stateRequests.last.event, 4);
        expect(observer.stateRequests.last.taskId, 1);
      },
    );

    test(
      'selects a frame within its queried page and pages values by cursor',
      () {
        executionStates.add(_executionState(1, -1));
        executionStates.add(_executionState(1, 5));
        cubit.dispatch(const SelectHistoryEvent(4));
        cubit.dispatch(
          const SelectHistorySurface(ExecutionHistorySurface.events),
        );
        cubit.dispatch(const SelectHistoryTask(1));

        expect(cubit.state.frameStart, 0);
        expect(cubit.state.selectedFrame, 39);
        expect(cubit.state.valueTotal, 65);
        expect(observer.valueRequests.last.pageSize, 64);

        cubit.dispatch(const SelectHistoryFramePage(32));
        expect(cubit.state.frameStart, 32);
        expect(cubit.state.selectedFrame, 7);
        cubit.dispatch(const SelectHistoryFrame(5));
        cubit.dispatch(const LoadNextValuePage());

        expect(cubit.state.selectedFrame, 5);
        expect(cubit.state.values.map((entry) => entry.name), [
          'value-0',
          'value-1',
        ]);
        expect(observer.stateRequests.last.startFrame, 32);
        expect(observer.valueRequests.last.event, 4);
        expect(observer.valueRequests.last.taskId, 1);
        expect(observer.valueRequests.last.frame, 5);
        expect(observer.valueRequests.last.cursor, 'cursor-0');
      },
    );

    test('moves a requested range and rejects a 4097 event read', () {
      executionStates.add(_executionState(1, -1));
      executionStates.add(_executionState(1, 5));
      cubit.dispatch(const SelectHistoryEvent(4));
      cubit.dispatch(const SelectHistoryRange(1, 2));

      expect(cubit.state.rangeStart, 1);
      expect(cubit.state.rangeEnd, 2);
      final requestCount = observer.historyRequests.length;
      cubit.dispatch(const SelectHistoryRange(1, 4097));

      expect(observer.historyRequests, hasLength(requestCount));
      expect(cubit.state.error, 'invalid_history_range');
    });

    test(
      'handles observation failures and events outside retained history',
      () {
        executionStates.add(_executionState(1, -1));
        executionStates.add(_executionState(1, 5));
        observer.failState = true;
        cubit.dispatch(
          const SelectHistorySurface(ExecutionHistorySurface.events),
        );

        expect(cubit.state.error, 'state_unavailable');
        observer.horizonFirst = 3;
        executionStates.add(_executionState(1, 6));
        cubit.dispatch(const SelectHistoryEvent(2));

        expect(cubit.state.error, 'event_outside_horizon');
        expect(cubit.state.liveEvent, 6);
      },
    );

    test(
      'reads at most 4096 events and drops data before a moved horizon',
      () async {
        await cubit.close();
        observer = _FakeObserver(events: _events(5001));
        cubit = _cubit(executionStates.stream, observer);
        executionStates.add(_executionState(2, -1));
        executionStates.add(_executionState(2, 0));
        observer.horizonFirst = 905;
        executionStates.add(_executionState(2, 5000));

        expect(observer.historyRequests.last.start, 905);
        expect(observer.historyRequests.last.count, 4096);
        expect(cubit.state.events, hasLength(4096));
        expect(cubit.state.events.first.index, 905);
        expect(cubit.state.events.last.index, 5000);
        expect(cubit.state.horizonFirst, 905);
      },
    );
  });

  test('reports missing observation ports without throwing', () async {
    final executionStates = StreamController<ExecutionState>.broadcast(
      sync: true,
    );
    final cubit = ExecutionHistoryCubit(
      executionStates: executionStates.stream,
      observer: null,
      flowProjector: const TaskFlowProjection(),
      structureProjector: const TaskStructureProjection(),
    );
    executionStates.add(_executionState(1, -1));
    executionStates.add(_executionState(1, 0));

    expect(cubit.state.error, 'observation_unavailable');
    await cubit.close();
    await executionStates.close();
  });
}

ExecutionHistoryCubit _cubit(
  Stream<ExecutionState> executionStates,
  ProgramExecutionObserver observer,
) => ExecutionHistoryCubit(
  executionStates: executionStates,
  observer: observer,
  flowProjector: const TaskFlowProjection(),
  structureProjector: const TaskStructureProjection(),
);

ExecutionState _executionState(int runId, int event) => ExecutionState(
  status: ExecutionStatus.pausedAtStatement,
  currentStep: ExecutionStep(
    stepNumber: event + 1,
    scopeName: 'global',
    scopeDepth: 1,
    eventIndex: event,
  ),
  outputLines: const [],
  runId: runId,
);

List<ExecutionHistoryEvent> _events(int count) => [
  for (var index = 0; index < count; index++)
    ExecutionHistoryEvent(
      index: index,
      taskId: index.isEven ? 0 : 1,
      eventClass: 'statement',
      line: index + 1,
      depth: 0,
      data: const {},
      revisionId: 'revision',
      nodeId: 'node-$index',
      sourceRange: null,
    ),
];

final class _FakeObserver implements ProgramExecutionObserver {
  final List<ExecutionHistoryEvent> events;
  final List<({int start, int count})> historyRequests = [];
  final List<({int event, int taskId, int startFrame, int frameCount})>
  stateRequests = [];
  final List<({int event, int taskId, int frame, int pageSize, String? cursor})>
  valueRequests = [];
  int horizonFirst = 0;
  bool failState = false;

  _FakeObserver({required this.events});

  int get horizonLast => events.isEmpty ? -1 : events.last.index;

  @override
  ExecutionObservationResult<ExecutionHistoryWindow> historyWindow({
    required int start,
    required int count,
  }) {
    historyRequests.add((start: start, count: count));
    if (start < horizonFirst || start > horizonLast) {
      return const ExecutionObservationUsage();
    }
    final result = [
      for (final event in events)
        if (event.index >= start && event.index < start + count) event,
    ];
    return ExecutionObservationValue(
      ExecutionHistoryWindow(
        first: start,
        count: result.length,
        horizonFirst: horizonFirst,
        horizonLast: horizonLast,
        events: result,
      ),
    );
  }

  @override
  ExecutionObservationResult<ExecutionObservationState> stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  }) {
    stateRequests.add((
      event: event,
      taskId: taskId,
      startFrame: startFrame,
      frameCount: frameCount,
    ));
    if (failState) {
      return const ExecutionObservationFailure('state_unavailable');
    }
    final frames = [
      for (
        var offset = startFrame;
        offset < 40 && offset < startFrame + frameCount;
        offset++
      )
        ExecutionObservedFrame(
          id: 39 - offset,
          name: 'frame-${39 - offset}',
          sourceId: 0,
          revisionId: 'revision',
          line: offset + 1,
          column: 1,
        ),
    ];
    return ExecutionObservationValue(
      ExecutionObservationState(
        event: event,
        taskId: taskId,
        totalFrames: 40,
        frames: frames,
        tasks: const [
          ExecutionObservedTask(taskId: 0, name: 'Root', state: 'running'),
          ExecutionObservedTask(taskId: 1, name: 'Task 1', state: 'waiting'),
        ],
      ),
    );
  }

  @override
  ExecutionObservationResult<ExecutionValuePage> valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  }) {
    valueRequests.add((
      event: event,
      taskId: taskId,
      frame: frame,
      pageSize: pageSize,
      cursor: cursor,
    ));
    final page = cursor == null ? 0 : 1;
    return ExecutionObservationValue(
      ExecutionValuePage(
        entries: [
          ExecutionValueEntry(
            name: 'value-$page',
            value: {'valor': 'page-$page'},
          ),
        ],
        total: 65,
        valuesRead: 1,
        truncated: page == 0,
        nextCursor: page == 0 ? 'cursor-0' : null,
      ),
    );
  }
}
