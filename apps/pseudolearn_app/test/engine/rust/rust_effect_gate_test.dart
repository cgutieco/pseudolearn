import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_capabilities.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_gate.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

import '../../fakes/fake_rust_transport.dart';

Map<String, Object?> pending(int sequence, String operation) => {
  'events': <Object?>[],
  'diagnostics': <Object?>[],
  'termination': {
    'kind': 'awaiting_effect',
    'effect_seq': sequence,
    'capability_kind': 'host',
    'operation': operation,
    'arguments_summary': '',
    'source_node_id': 1,
  },
  'pending_effect': {
    'effect_seq': sequence,
    'operation': operation,
    'receiver': null,
    'arguments': <Object?>[],
    'result_capability': {'slot': 0, 'generation': 1, 'rights': 4, 'kind': 3},
  },
};

Map<String, Object?> completed() => {
  'events': <Object?>[],
  'diagnostics': <Object?>[],
  'termination': {'kind': 'completed'},
};

const SimulatedCapabilities clockCapabilities = SimulatedCapabilities(
  permissions: {'reloj'},
  clockStartNanos: 100,
);

FakeRustTransport scripted(
  List<Map<String, Object?>> batches,
  List<Map<String, Object?>> answers,
  List<Map<String, Object?>> started,
) {
  var next = 0;
  return FakeRustTransport({
    'create_analysis': (_) => {'resource': 2, 'document': 1},
    'analysis': (_) => {'tree': true, 'diagnostics': <Object?>[]},
    'program_view': (_) => {
      'revision_id': 'rev1',
      'child_order': 'source',
      'units': <Object?>[],
      'nodes': <Object?>[],
      'members': <Object?>[],
      'inheritance': <Object?>[],
      'methods': <Object?>[],
    },
    'start': (arguments) {
      started.add(arguments);
      return {'resource': 3};
    },
    'advance': (_) =>
        batches[next < batches.length ? next++ : batches.length - 1],
    'effect_result': (arguments) {
      answers.add(arguments);
      return null;
    },
    'cancel': (_) => null,
    'release': (_) => null,
  });
}

FakeRustTransport settling(int effects, List<int> answers) {
  var answered = 0;
  return FakeRustTransport({
    ...scripted([], [], []).handlers,
    'advance': (_) => answered < effects
        ? {
            ...pending(answered + 1, 'clock_now'),
            'events': [
              {'class': 'statement_entered', 'line': 2, 'depth': 1},
            ],
          }
        : completed(),
    'effect_result': (arguments) {
      answers.add(arguments['effect_seq'] as int);
      answered++;
      return null;
    },
  });
}

int advances(FakeRustTransport transport) =>
    transport.calls.where((call) => call == 'advance').length;

void main() {
  group('RustEffectGate', () {
    test(
      'answers pending effects with the sequence and drains to completion',
      () {
        final answers = <Map<String, Object?>>[];
        final transport = scripted(
          [pending(1, 'request_clock'), pending(2, 'clock_now'), completed()],
          answers,
          [],
        );
        final gate = RustEffectGate(transport, clockCapabilities, true);
        final batch = gate.drain(3, 25, []);
        expect(batch.termination, RustTerminationKind.completed);
        expect(answers.map((answer) => answer['effect_seq']), [1, 2]);
      },
    );

    test('without capabilities nothing is answered', () {
      final answers = <Map<String, Object?>>[];
      final transport = scripted([pending(1, 'request_clock')], answers, []);
      final gate = RustEffectGate(transport, SimulatedCapabilities.none, true);
      final batch = gate.drain(3, 25, []);
      expect(batch.termination, RustTerminationKind.awaitingEffect);
      expect(gate.canResolve, isFalse);
      expect(answers, isEmpty);
    });

    test('manual mode stops at the first pending effect', () {
      final answers = <Map<String, Object?>>[];
      final transport = scripted([pending(1, 'request_clock')], answers, []);
      final gate = RustEffectGate(transport, clockCapabilities, false);
      expect(
        gate.drain(3, 25, []).termination,
        RustTerminationKind.awaitingEffect,
      );
      expect(answers, isEmpty);
    });
  });

  group('bounded effect draining', () {
    test('one drain answers at most the budget and yields as running', () {
      final answers = <int>[];
      final transport = settling(40, answers);
      final gate = RustEffectGate(transport, clockCapabilities, true);
      final batch = gate.drain(3, 25, []);
      expect(answers, hasLength(RustEffectGate.maxResolutionsPerDrain));
      expect(batch.termination, RustTerminationKind.running);
      expect(batch.pendingEffect, isNull);
      expect(advances(transport), RustEffectGate.maxResolutionsPerDrain + 1);
    });

    test('successive drains answer every effect once and in order', () {
      final answers = <int>[];
      final transport = settling(40, answers);
      final gate = RustEffectGate(transport, clockCapabilities, true);
      var batch = gate.drain(3, 25, []);
      var drains = 1;
      while (batch.termination == RustTerminationKind.running) {
        batch = gate.drain(3, 25, []);
        drains++;
      }
      expect(batch.termination, RustTerminationKind.completed);
      expect(answers, [for (var sequence = 1; sequence <= 40; sequence++) sequence]);
      expect(drains, 3);
    });

    test('exactly the budget does not yield', () {
      final answers = <int>[];
      final gate = RustEffectGate(
        settling(RustEffectGate.maxResolutionsPerDrain, answers),
        clockCapabilities,
        true,
      );
      expect(
        gate.drain(3, 25, []).termination,
        RustTerminationKind.completed,
      );
    });

    test('one command never exceeds the per-call transport bound', () {
      final transport = settling(100, []);
      final execution = RustProgramExecution(
        transport,
        capabilities: clockCapabilities,
      );
      execution.startExecution(
        sourceCode: 'Algoritmo P\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      var largest = 0;
      for (var index = 0; index < 400; index++) {
        final before = transport.calls.length;
        final step = execution.step();
        final used = transport.calls.length - before;
        if (used > largest) largest = used;
        if (step.isTerminal) break;
      }
      expect(largest, lessThanOrEqualTo(2 * RustEffectGate.maxResolutionsPerDrain + 1));
      expect(largest, greaterThan(1));
    });

    test('manual mode and a stop between batches leave nothing answered', () {
      final answers = <int>[];
      final transport = settling(40, answers);
      final execution = RustProgramExecution(
        transport,
        capabilities: clockCapabilities,
      );
      execution.startExecution(
        sourceCode: 'Algoritmo P\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      execution.step();
      final answered = answers.length;
      execution.stop();
      expect(answers, hasLength(answered));
      expect(execution.step().isTerminal, isTrue);
      expect(answers, hasLength(answered));
    });
  });

  group('RustProgramExecution effects', () {
    RustProgramExecution begin(
      FakeRustTransport transport, {
      bool auto = true,
    }) {
      final execution = RustProgramExecution(
        transport,
        capabilities: clockCapabilities,
        autoResolveEffects: auto,
      );
      execution.startExecution(
        sourceCode: 'Algoritmo P\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      return execution;
    }

    test('start declares the simulated host to the engine', () {
      final started = <Map<String, Object?>>[];
      begin(scripted([completed()], [], started));
      expect(started.single['host'], {
        'permissions': ['reloj'],
        'detached': true,
        'clock': [100],
      });
    });

    test('manual mode exposes the wait and settles it on request', () {
      final answers = <Map<String, Object?>>[];
      final transport = scripted(
        [pending(1, 'request_clock'), completed()],
        answers,
        [],
      );
      final execution = begin(transport, auto: false);
      final waiting = execution.step();
      expect(waiting.isAwaitingEffect, isTrue);
      expect(waiting.pendingEffect?.sequence, 1);
      expect(waiting.pendingEffect?.operation, 'request_clock');
      final finished = execution.settleEffect(EffectSettlement.resolve);
      expect(answers.single['effect_seq'], 1);
      expect(finished.isFinished, isTrue);
    });

    test('cancelling a wait halts the execution without answering', () {
      final answers = <Map<String, Object?>>[];
      final transport = scripted([pending(1, 'request_clock')], answers, []);
      final execution = begin(transport, auto: false);
      execution.step();
      final cancelled = execution.settleEffect(EffectSettlement.cancel);
      expect(cancelled.isHalted, isTrue);
      expect(cancelled.haltReason, 'cancelled');
      expect(answers, isEmpty);
      expect(transport.calls, contains('cancel'));
      expect(transport.calls, contains('release'));
    });
  });
}
