import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_tape.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';
import 'rust_program_execution_test.dart' show batch, event, transportWith;

const Map<String, Object?> tapeDocument = {
  'format': 'pseudolearn.tape/v1',
  'entries': [
    {'seq': 1, 'kind': 'request_clock'},
  ],
};

List<Map<String, Object?>> programEvents() => [
  event('statement_entered', node: 'n1'),
  event('call', node: 'n1'),
  event('statement_entered', node: 'n1'),
  event('return', node: 'n1'),
  event('statement_entered', node: 'n1'),
];

List<Map<String, Object?>> partition(int size, {bool withTape = true}) {
  final events = programEvents();
  final batches = <Map<String, Object?>>[];
  for (var from = 0; from < events.length; from += size) {
    final to = from + size < events.length ? from + size : events.length;
    final last = to == events.length;
    batches.add({
      ...batch(
        events.sublist(from, to),
        last ? {'kind': 'completed'} : {'kind': 'running'},
      ),
      if (withTape) 'effect_tape': tapeDocument,
    });
  }
  return batches;
}

RustProgramExecution begin(FakeRustTransport transport, {EffectTape? tape}) {
  final execution = RustProgramExecution(transport);
  execution.startExecution(
    sourceCode: 'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n',
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    replayTape: tape,
  );
  return execution;
}

ExecutionStep drive(RustProgramExecution execution) {
  var step = execution.step();
  for (var count = 0; count < 100 && !step.isTerminal; count++) {
    step = execution.step();
  }
  return step;
}

FakeRustTransport recording(
  List<Map<String, Object?>> batches,
  List<Map<String, Object?>> started,
) => transportWith(
  batches: batches,
  extra: {
    'start': (arguments) {
      started.add(arguments);
      return {'resource': 3};
    },
  },
);

void main() {
  group('RustProgramExecution reproduction', () {
    test('the live run exposes the recorded tape and a projection', () {
      final live = begin(recording(partition(5), []));
      drive(live);
      expect(live.recordedTape, EffectTape.fromDocument(tapeDocument));
      expect(live.projection.events, hasLength(5));
      expect(live.projection.termination, 'completed');
      expect(live.replayRejection, isNull);
    });

    test('replay requests the tape mode and sends the recorded tape', () {
      final started = <Map<String, Object?>>[];
      begin(
        recording(partition(5), started),
        tape: EffectTape.fromDocument(tapeDocument),
      );
      expect(started.single['execution_mode'], 'replay_from_tape');
      expect(started.single['effect_tape'], tapeDocument);
      expect(started.single.containsKey('host'), isFalse);
    });

    test('live runs never send a mode or a tape', () {
      final started = <Map<String, Object?>>[];
      begin(recording(partition(5), started));
      expect(started.single.containsKey('execution_mode'), isFalse);
      expect(started.single.containsKey('effect_tape'), isFalse);
    });

    for (final size in [1, 2, 3, 5, 25]) {
      test('replay with batches of $size equals the recorded projection', () {
        final live = begin(recording(partition(5), []));
        drive(live);
        final transport = recording(partition(size), []);
        final replay = begin(transport, tape: live.recordedTape);
        drive(replay);
        expect(replay.projection.termination, 'completed');
        expect(replay.projection.firstDivergence(live.projection), isNull);
        expect(replay.projection, live.projection);
        expect(transport.calls, isNot(contains('effect_result')));
        expect(transport.calls, isNot(contains('input')));
      });
    }

    test('a replay that produces another event is reported as divergent', () {
      final live = begin(recording(partition(5), []));
      drive(live);
      final changed = programEvents()
        ..[3] = event('return', node: 'n1', depth: 2);
      final replay = begin(
        recording([
          batch(changed, {'kind': 'completed'}),
        ], []),
        tape: live.recordedTape,
      );
      drive(replay);
      expect(replay.projection.firstDivergence(live.projection), 3);
    });

    test('pausing between steps does not change the projection', () {
      final live = begin(recording(partition(5), []));
      drive(live);
      final replay = begin(
        recording(partition(2), []),
        tape: live.recordedTape,
      );
      replay.step();
      replay.outputLines;
      replay.projection;
      replay.recordedTape;
      drive(replay);
      expect(replay.projection, live.projection);
    });

    test('reading the reproduction never calls the engine', () {
      final transport = recording(partition(5), []);
      final live = begin(transport);
      drive(live);
      final before = transport.calls.length;
      live.recordedTape;
      live.projection;
      live.replayRejection;
      live.outputLines;
      expect(transport.calls.length, before);
    });

    final startFailures = {
      'replay_identity_mismatch': ReplayRejection.identityMismatch,
      'replay_corrupted_tape': ReplayRejection.corruptedTape,
      'replay_non_reproducible': ReplayRejection.nonReproducible,
      'replay_truncated_tape': ReplayRejection.truncatedTape,
      'replay_divergence': ReplayRejection.divergence,
    };
    for (final entry in startFailures.entries) {
      test('${entry.key} at start is a typed rejection without a run', () {
        final transport = transportWith(
          batches: partition(5),
          extra: {
            'start': (_) => throw RustBridgeFailure(
              family: 'usage',
              detail: 'Invalid protocol: ${entry.key}',
            ),
          },
        );
        final execution = begin(
          transport,
          tape: EffectTape.fromDocument(tapeDocument),
        );
        expect(execution.replayRejection, entry.value);
        expect(execution.step().isTerminal, isTrue);
        expect(transport.calls, isNot(contains('advance')));
        expect(transport.calls, contains('release'));
      });
    }

    test('a rejection during replay fails the run with its code', () {
      var calls = 0;
      final transport = transportWith(
        batches: partition(1),
        extra: {
          'advance': (_) {
            if (calls++ == 0) {
              return batch(
                [event('statement_entered', node: 'n1')],
                {'kind': 'running'},
              );
            }
            throw const RustBridgeFailure(
              family: 'usage',
              detail: 'Invalid protocol: replay_truncated_tape',
            );
          },
        },
      );
      final replay = begin(
        transport,
        tape: EffectTape.fromDocument(tapeDocument),
      );
      final last = drive(replay);
      expect(last.isTerminal, isTrue);
      expect(replay.replayRejection, ReplayRejection.truncatedTape);
      expect(replay.projection.failure, 'replay_truncated_tape');
      expect(replay.projection.termination, 'failed');
      expect(transport.calls, isNot(contains('effect_result')));
    });

    test('a live failure from the engine is not hidden as a rejection', () {
      final transport = transportWith(
        batches: partition(5),
        extra: {
          'advance': (_) =>
              throw const RustBridgeFailure(family: 'internal', detail: 'boom'),
        },
      );
      final live = begin(transport);
      expect(live.step, throwsA(isA<RustBridgeFailure>()));
      expect(live.replayRejection, isNull);
    });

    test('a new start clears the tape and rejection of the previous run', () {
      final live = begin(recording(partition(5), []));
      drive(live);
      expect(live.recordedTape, isNotNull);
      live.startExecution(
        sourceCode: 'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(live.projection.events, isEmpty);
      live.stop();
      expect(live.projection.termination, 'running');
    });

    test('replay without host capabilities declares no host', () {
      final started = <Map<String, Object?>>[];
      begin(
        recording(partition(5), started),
        tape: EffectTape.fromDocument(tapeDocument),
      );
      expect(started.single.containsKey('host'), isFalse);
    });
  });
}
