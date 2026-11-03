import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_gate.dart';
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
