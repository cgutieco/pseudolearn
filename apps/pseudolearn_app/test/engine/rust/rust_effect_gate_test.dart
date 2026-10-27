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
      'units': <Object?>[],
      'nodes': <Object?>[],
      'members': <Object?>[],
      'inheritance': <Object?>[],
    },
    'start': (arguments) {
      started.add(arguments);
      return {'resource': 3};
    },
    'advance': (_) => batches[next < batches.length ? next++ : batches.length - 1],
    'effect_result': (arguments) {
      answers.add(arguments);
      return null;
    },
    'cancel': (_) => null,
    'release': (_) => null,
  });
}

void main() {
  group('RustEffectGate', () {
    test('answers pending effects with the sequence and drains to completion', () {
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
    });

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
      expect(gate.drain(3, 25, []).termination, RustTerminationKind.awaitingEffect);
      expect(answers, isEmpty);
    });
  });

  group('RustProgramExecution effects', () {
    RustProgramExecution begin(FakeRustTransport transport, {bool auto = true}) {
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
    });
  });
}
