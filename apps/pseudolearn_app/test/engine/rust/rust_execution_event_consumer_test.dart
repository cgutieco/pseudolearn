import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_event_consumer.dart';
import 'package:pseudolearn_app/engine/rust/rust_focus_tracker.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

import '../../fakes/fake_rust_transport.dart';

const _emptyViewWire = <String, Object?>{
  'revision_id': 'revision',
  'child_order': 'source',
  'units': <Object?>[],
  'nodes': <Object?>[],
  'members': <Object?>[],
  'inheritance': <Object?>[],
  'methods': <Object?>[],
};

RustProgramView _emptyView() {
  final result = RustProgramView.decode(_emptyViewWire, SourceOffsetIndex(''));
  return (result as RustProgramViewReadSuccess).view;
}

RustEvent _outputEvent({String revision = 'revision'}) => RustEvent(
  eventClass: 'output',
  line: 1,
  depth: 1,
  data: const {'texto': 'hola'},
  sourceRevisionId: revision,
);

RustEvent _taskEvent(String eventClass, Map<String, Object?> data) => RustEvent(
  eventClass: eventClass,
  line: 1,
  depth: 1,
  data: data,
  sourceRevisionId: 'revision',
);

String? _consumeAll(
  RustExecutionEventConsumer consumer,
  RustFocusTracker tracker,
  RustProgramView view,
  List<RustEvent> events,
) {
  String? failure;
  for (final (index, event) in events.indexed) {
    failure = consumer.consume(
      event: event,
      eventIndex: index,
      execution: 3,
      view: view,
      offsets: SourceOffsetIndex(''),
      tracker: tracker,
    );
    if (failure != null) return failure;
  }
  return failure;
}

final _spawnedChild = [
  _taskEvent('task_spawned', const {'task': 1, 'parent': 0, 'scope': 0}),
  _taskEvent('task_ready', const {'task': 1, 'cause': 'spawn'}),
];

void main() {
  test('a task resumed only to finish its cancellation needs no state', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    final failure = _consumeAll(consumer, tracker, view, [
      ..._spawnedChild,
      _taskEvent('task_cancel_requested', const {
        'task': 1,
        'reason': 'sibling_failure',
        'origin': 0,
      }),
      _taskEvent('task_resumed', const {'task': 1}),
    ]);

    expect(failure, isNull);
    expect(tracker.currentTaskId, 1);
    expect(tracker.variables, isEmpty);
  });

  test('a running task whose state is unavailable halts the step', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    final failure = _consumeAll(consumer, tracker, view, [
      ..._spawnedChild,
      _taskEvent('task_resumed', const {'task': 1}),
    ]);

    expect(failure, 'task_state_unavailable');
  });

  test('without variable observation a resumed task reads no state', () {
    final transport = FakeRustTransport({});
    final consumer = RustExecutionEventConsumer(transport)
      ..observesEnvironment = false;
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    final failure = _consumeAll(consumer, tracker, view, [
      ..._spawnedChild,
      _taskEvent('task_resumed', const {'task': 1}),
    ]);

    expect(failure, isNull);
    expect(tracker.currentTaskId, 1);
    expect(transport.calls, isNot(contains('query_frame')));
  });

  test('without variable observation output is still recorded', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}))
      ..observesEnvironment = false;
    final view = _emptyView();

    final failure = consumer.consume(
      event: _outputEvent(),
      eventIndex: 0,
      execution: 3,
      view: view,
      offsets: SourceOffsetIndex(''),
      tracker: RustFocusTracker(view),
    );

    expect(failure, isNull);
    expect(consumer.outputLines.map((line) => line.text), ['hola']);
  });

  test('records output after applying a valid event', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    final failure = consumer.consume(
      event: _outputEvent(),
      eventIndex: 0,
      execution: 3,
      view: view,
      offsets: SourceOffsetIndex(''),
      tracker: tracker,
    );

    expect(failure, isNull);
    expect(consumer.outputLines.map((line) => line.text), ['hola']);
  });

  test('rejects an event from another revision before recording output', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    final failure = consumer.consume(
      event: _outputEvent(revision: 'old-revision'),
      eventIndex: 0,
      execution: 3,
      view: view,
      offsets: SourceOffsetIndex(''),
      tracker: tracker,
    );

    expect(failure, 'invalid_event_sequence');
    expect(consumer.outputLines, isEmpty);
  });

  test('marks output inside an error range as program error', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);
    RustEvent event(String text) => RustEvent(
      eventClass: 'output',
      line: 1,
      depth: 1,
      data: {'texto': text},
      sourceRevisionId: 'revision',
    );

    for (final (index, text) in ['ok\n', 'mal\n', 'ñ\n'].indexed) {
      consumer.consume(
        event: event(text),
        eventIndex: index,
        execution: 3,
        view: view,
        offsets: SourceOffsetIndex(''),
        tracker: tracker,
        errorRanges: const [(3, 7)],
      );
    }

    expect(consumer.outputLines.map((line) => line.kind), [
      OutputLineKind.programOutput,
      OutputLineKind.programError,
      OutputLineKind.programOutput,
    ]);
  });

  test('keeps output outside every error range as program output', () {
    final consumer = RustExecutionEventConsumer(FakeRustTransport({}));
    final view = _emptyView();
    final tracker = RustFocusTracker(view);

    consumer.consume(
      event: _outputEvent(),
      eventIndex: 0,
      execution: 3,
      view: view,
      offsets: SourceOffsetIndex(''),
      tracker: tracker,
      errorRanges: const [(10, 20)],
    );

    expect(consumer.outputLines.single.kind, OutputLineKind.programOutput);
  });
}
