import 'package:flutter_test/flutter_test.dart';
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
}
