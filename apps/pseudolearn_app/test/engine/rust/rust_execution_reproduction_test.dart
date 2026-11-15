import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/engine/rust/rust_event_signature.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_reproduction.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

RustEvent event(String name, {int line = 2, int? taskId, String? nodeId}) =>
    RustEvent(
      eventClass: name,
      line: line,
      depth: 1,
      data: const {},
      taskId: taskId,
      nodeId: nodeId,
    );

RustBatch batchWith(Map<String, Object?>? tape) => RustBatch(
  events: const [],
  termination: RustTerminationKind.completed,
  effectTape: tape,
);

void main() {
  group('RustExecutionReproduction', () {
    test('the signature separates tasks, nodes, lines and data', () {
      final base = rustEventSignature(event('call'));
      expect(
        rustEventSignature(event('call', taskId: 1)),
        isNot(base),
      );
      expect(
        rustEventSignature(event('call', nodeId: 'n1')),
        isNot(base),
      );
      expect(
        rustEventSignature(event('call', line: 3)),
        isNot(base),
      );
      expect(rustEventSignature(event('call')), base);
    });

    test('the signature ignores the revision label but keeps the node', () {
      RustEvent at(String revision, String node) => RustEvent(
        eventClass: 'call',
        line: 2,
        depth: 1,
        data: const {},
        sourceRevisionId: revision,
        nodeId: node,
      );
      expect(
        rustEventSignature(at('rev1', 'rev1.n24')),
        rustEventSignature(at('rev4', 'rev4.n24')),
      );
      expect(
        rustEventSignature(at('rev1', 'rev1.n24')),
        isNot(rustEventSignature(at('rev1', 'rev1.n25'))),
      );
    });

    test('projection lists consumed events in order with output', () {
      final reproduction = RustExecutionReproduction()
        ..begin(replaying: false)
        ..consumed(event('call'))
        ..consumed(event('return'));
      final projection = reproduction.projection(
        termination: RustTerminationKind.completed,
        output: const [
          OutputLine(text: 'x', kind: OutputLineKind.programOutput),
        ],
      );
      expect(projection.events, hasLength(2));
      expect(projection.output, ['programOutput:x']);
      expect(projection.termination, 'completed');
    });

    test('the projection is unmodifiable', () {
      final reproduction = RustExecutionReproduction()..begin(replaying: false);
      final projection = reproduction.projection(
        termination: RustTerminationKind.running,
        output: const [],
      );
      expect(() => projection.events.add('x'), throwsUnsupportedError);
    });

    test('the latest tape is kept and a batch without tape does not erase it', () {
      final reproduction = RustExecutionReproduction()..begin(replaying: false);
      expect(reproduction.recordedTape, isNull);
      reproduction
        ..observed(batchWith({'entries': [1]}))
        ..observed(batchWith(null));
      expect(reproduction.recordedTape?.toDocument(), {'entries': [1]});
    });

    test('begin clears tape, events, rejection and the replay flag', () {
      final reproduction = RustExecutionReproduction()
        ..begin(replaying: true)
        ..consumed(event('call'))
        ..observed(batchWith({'entries': []}))
        ..reject(const RustBridgeFailure(family: 'usage', detail: 'x'));
      expect(reproduction.rejection, ReplayRejection.engineRefused);
      reproduction.begin(replaying: false);
      expect(reproduction.rejection, isNull);
      expect(reproduction.recordedTape, isNull);
      expect(reproduction.replaying, isFalse);
      expect(
        reproduction
            .projection(termination: RustTerminationKind.running, output: [])
            .events,
        isEmpty,
      );
    });
  });
}
