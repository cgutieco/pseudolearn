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

void main() {
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
