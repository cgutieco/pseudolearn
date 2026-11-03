import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/task_flow_scene.dart';
import 'package:pseudolearn_app/domain/model/execution/task_structure_scene.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';

import 'task_scene_runner.dart';

const List<int> taskLoads = [0, 1, 10, 100];
const int windowEvents = 100;
const int wideWindowEvents = 4096;
const int iterationsPerLoad = 30;

typedef MeasuredLoad = ({int tasks, int window});

const List<MeasuredLoad> loads = [
  (tasks: 0, window: windowEvents),
  (tasks: 1, window: windowEvents),
  (tasks: 10, window: windowEvents),
  (tasks: 100, window: windowEvents),
  (tasks: 100, window: wideWindowEvents),
];

void main() {
  final outputPath = Platform.environment['TASK_PROJECTION_OUTPUT'];
  if (outputPath == null) {
    test(
      'measurement is disabled without an output path',
      () {},
      skip: 'Set TASK_PROJECTION_OUTPUT to a JSONL output file.',
    );
    return;
  }

  test('records reproducible task projection measurements', () async {
    final output = File(outputPath);
    await output.parent.create(recursive: true);
    final sink = output.openWrite();
    final ticksPerSecond = _ticksPerSecond();
    final resolution = _clockResolutionTicks();
    const flow = TaskFlowProjection();
    const structure = TaskStructureProjection();

    for (var iteration = 0; iteration < iterationsPerLoad; iteration++) {
      for (final load in loads) {
        final prepared = _prepare(load);

        final pureClock = Stopwatch()..start();
        final flowScene = flow.project(
          events: prepared.events,
          rangeStart: prepared.events.first.index,
          rangeEnd: prepared.events.last.index,
          width: 1200,
        );
        final structureScene = structure.project(
          events: prepared.events,
          horizonFirst: prepared.horizonFirst,
          taskContexts: prepared.step.taskContexts,
        );
        pureClock.stop();

        final integratedBefore = prepared.run.transport.hashCode;
        final integratedClock = Stopwatch()..start();
        final window = prepared.run.observer.historyWindow(
          start: prepared.windowStart,
          count: load.window,
        );
        final read =
            (window as ExecutionObservationValue<ExecutionHistoryWindow>).value;
        final integratedFlow = flow.project(
          events: read.events,
          rangeStart: read.events.first.index,
          rangeEnd: read.events.last.index,
          width: 1200,
        );
        integratedClock.stop();

        _expectEquivalent(prepared, flowScene, structureScene, integratedFlow);
        expect(prepared.run.transport.hashCode, integratedBefore);

        sink.writeln(
          jsonEncode({
            'process_id': pid,
            'iteration': iteration,
            'task_count': load.tasks,
            'window_events': load.window,
            'retained_events': prepared.totalEvents,
            'horizon_first': prepared.horizonFirst,
            'visible_events': prepared.events.length,
            'visible_tasks': flowScene.lanes.length,
            'structure_tasks': structureScene.tasks.length,
            'flow_markers': flowScene.markers.length,
            'flow_connectors': flowScene.connectors.length,
            'clock_ticks_per_second': ticksPerSecond,
            'clock_resolution_ticks': resolution,
            'pure_projection_ns': _nanoseconds(pureClock, ticksPerSecond),
            'integrated_ns': _nanoseconds(integratedClock, ticksPerSecond),
            'rss_bytes': ProcessInfo.currentRss,
          }),
        );
        prepared.run.execution.stop();
      }
    }
    await sink.flush();
    await sink.close();
  }, timeout: const Timeout(Duration(minutes: 30)));
}

final class _Prepared {
  final TaskSceneRun run;
  final ExecutionStep step;
  final List<ExecutionHistoryEvent> events;
  final int windowStart;
  final int totalEvents;
  final int horizonFirst;
  final int tasks;

  _Prepared(
    this.run,
    this.step,
    this.events,
    this.windowStart,
    this.totalEvents,
    this.horizonFirst,
    this.tasks,
  );
}

_Prepared _prepare(MeasuredLoad load) {
  final run = TaskSceneRun.open();
  final step = run.until(
    run.execution.startExecution(
      sourceCode: _programOf(load.tasks),
      profileId: SceneLanguage.english.profile,
      languageId: SceneLanguage.english.interfaceLanguage,
    ),
    (step) => step.isFinished,
    bound: 20000,
  );
  expect(step.isFinished, isTrue);
  expect(step.taskContexts.length, load.tasks + 1);
  final retained =
      (run.observer.historyWindow(start: 0, count: 4096)
              as ExecutionObservationValue<ExecutionHistoryWindow>)
          .value;
  final all = retained.events;
  final count = all.length < load.window ? all.length : load.window;
  final start = all.length - count;
  final window = all.sublist(start);
  final horizon = retained.horizonFirst;
  return _Prepared(
    run,
    step,
    window,
    window.first.index,
    all.length,
    horizon,
    load.tasks,
  );
}

void _expectEquivalent(
  _Prepared prepared,
  TaskFlowScene pure,
  TaskStructureScene structure,
  TaskFlowScene integrated,
) {
  expect(pure.markers.length, prepared.events.length);
  expect(integrated.markers.length, pure.markers.length);
  expect(
    integrated.lanes.map((lane) => lane.taskId),
    pure.lanes.map((lane) => lane.taskId),
  );
  expect(structure.tasks.length, inInclusiveRange(1, prepared.tasks + 1));
  expect(pure.lanes.length, lessThanOrEqualTo(prepared.tasks + 1));
  if (prepared.horizonFirst == 0 &&
      prepared.events.length == prepared.totalEvents) {
    expect(pure.lanes.length, prepared.tasks + 1);
  }
}

String _programOf(int tasks) {
  if (tasks == 0) return 'algorithm Main\nwrite 1;\nendAlgorithm\n';
  final spawns = [
    for (var index = 0; index < tasks; index++) 'spawn Work($index);',
  ];
  return [
    'subroutine suspendable Work(marker as integer)',
    'write marker;',
    'endSubroutine',
    'algorithm Main',
    'tasks',
    ...spawns,
    'endTasks',
    'endAlgorithm',
    '',
  ].join('\n');
}

double _ticksPerSecond() {
  final clock = Stopwatch()..start();
  while (clock.elapsedMicroseconds < 100000) {}
  clock.stop();
  return clock.elapsedTicks * 1000000 / clock.elapsedMicroseconds;
}

int _clockResolutionTicks() {
  final clock = Stopwatch()..start();
  var previous = clock.elapsedTicks;
  var minimum = 0;
  for (var attempt = 0; attempt < 10000; attempt++) {
    final current = clock.elapsedTicks;
    final delta = current - previous;
    if (delta > 0 && (minimum == 0 || delta < minimum)) minimum = delta;
    previous = current;
  }
  clock.stop();
  return minimum;
}

int _nanoseconds(Stopwatch clock, double ticksPerSecond) =>
    (clock.elapsedTicks * 1000000000 / ticksPerSecond).round();
