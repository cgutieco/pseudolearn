import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_gate.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_policy.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';
import '../../fakes/fake_rust_transport.dart';

void main() {
  const raw = {
    'effect_seq': 7,
    'operation': 'clock_now',
    'arguments': <Object?>[],
  };
  const batch = RustBatch(
    events: [],
    termination: RustTerminationKind.awaitingEffect,
    pendingRequests: [raw],
  );

  test('a pending physical effect yields until its matching reply arrives', () {
    final submitted = <Object?>[];
    final delivered = <Object?>[];
    var ready = false;
    final transport = FakeRustTransport({
      'host_open': (_) => null,
      'host_submit': (arguments) {
        submitted.add(arguments['effect']);
        return null;
      },
      'host_poll': (_) => ready
          ? [
              {
                'effect_seq': 7,
                'result': {'outcome': 'committed'},
              },
            ]
          : [],
      'effect_result': (arguments) {
        delivered.add(arguments);
        return null;
      },
      'host_close': (_) => null,
    });
    final gate = RustEffectGate(transport, null, true);
    gate.reset(
      const ExecutionConfiguration(arguments: ['á b', '']),
      replaying: false,
    );
    expect(gate.answer(3, batch), isFalse);
    expect(delivered, isEmpty);
    ready = true;
    expect(gate.answer(3, batch), isTrue);
    expect(submitted, [raw, raw]);
    expect(delivered.single, containsPair('effect_seq', 7));
    expect(
      transport.calls.where((operation) => operation == 'host_open').length,
      1,
    );
    gate.close();
    gate.close();
    expect(
      transport.calls.where((operation) => operation == 'host_close').length,
      1,
    );
  });

  test('a contained gate refuses a directory request without opening a host', () {
    final delivered = <Map<String, Object?>>[];
    final transport = FakeRustTransport({
      'effect_result': (arguments) {
        delivered.add(arguments);
        return null;
      },
    });
    final gate = RustEffectGate(
      transport,
      null,
      true,
      policy: const RustEffectPolicy.contained(),
    );
    gate.reset(const ExecutionConfiguration(), replaying: false);
    const directoryBatch = RustBatch(
      events: [],
      termination: RustTerminationKind.awaitingEffect,
      pendingRequests: [
        {'effect_seq': 4, 'operation': 'request_directory'},
      ],
    );
    expect(gate.answer(3, directoryBatch), isTrue);
    expect(delivered.single, containsPair('effect_seq', 4));
    expect(transport.calls, isNot(contains('host_open')));
    expect(transport.calls, isNot(contains('host_submit')));
  });

  test('a contained gate still resolves console effects on the host', () {
    final submitted = <Object?>[];
    final delivered = <Map<String, Object?>>[];
    final transport = FakeRustTransport({
      'host_open': (_) => null,
      'host_submit': (arguments) {
        submitted.add(arguments['effect']);
        return null;
      },
      'host_poll': (_) => [
        {
          'effect_seq': 5,
          'result': {'outcome': 'committed'},
        },
      ],
      'effect_result': (arguments) {
        delivered.add(arguments);
        return null;
      },
    });
    final gate = RustEffectGate(
      transport,
      null,
      true,
      policy: const RustEffectPolicy.contained(),
    );
    gate.reset(const ExecutionConfiguration(), replaying: false);
    const mixedBatch = RustBatch(
      events: [],
      termination: RustTerminationKind.awaitingEffect,
      pendingRequests: [
        {'effect_seq': 5, 'operation': 'console_write'},
        {'effect_seq': 6, 'operation': 'network_send'},
      ],
    );
    expect(gate.answer(3, mixedBatch), isTrue);
    expect(submitted, [
      {'effect_seq': 5, 'operation': 'console_write'},
    ]);
    expect(delivered.map((reply) => reply['effect_seq']), containsAll([5, 6]));
  });

  test('a contained gate with nothing pending reports no progress', () {
    final transport = FakeRustTransport({});
    final gate = RustEffectGate(
      transport,
      null,
      true,
      policy: const RustEffectPolicy.contained(),
    );
    gate.reset(const ExecutionConfiguration(), replaying: false);
    const emptyBatch = RustBatch(
      events: [],
      termination: RustTerminationKind.awaitingEffect,
    );
    expect(gate.answer(3, emptyBatch), isFalse);
    expect(transport.calls, isEmpty);
  });

  test('replay never activates a physical host', () {
    final transport = FakeRustTransport({});
    final gate = RustEffectGate(transport, null, true);
    gate.reset(const ExecutionConfiguration(), replaying: true);
    expect(gate.canResolve, isFalse);
    expect(gate.answer(3, batch), isFalse);
    gate.close();
    expect(transport.calls, isEmpty);
  });
}
